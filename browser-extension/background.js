// background.js
var apiKey = null;

function loadApiKey() {
  chrome.storage.sync.get(['groqApiKey'], function(result) {
    apiKey = result.groqApiKey || null;
    console.log('API key loaded:', apiKey ? 'Yes' : 'No');
  });
}

chrome.runtime.onStartup.addListener(loadApiKey);
chrome.runtime.onInstalled.addListener(loadApiKey);

chrome.runtime.onMessage.addListener(function(msg, sender, sendResponse) {
  if (msg.action === "analyzeText") {
    analyzeText(msg.text, msg.buttonText)
      .then(function(result) {
        sendResponse({ result: result });
      })
      .catch(function(error) {
        console.error("Analysis error:", error);
        sendResponse({ result: "SAFE" });
      });
    
    return true;
  } else if (msg.action === "reloadConfig") {
    loadApiKey();
    sendResponse({ success: true });
  }
});

function analyzeText(text, buttonText) {
  return new Promise(function(resolve, reject) {
    if (!apiKey) {
      chrome.storage.sync.get(['groqApiKey'], function(result) {
        apiKey = result.groqApiKey;
        
        if (!apiKey) {
          console.error("API key not configured. Please set it in extension options.");
          chrome.runtime.openOptionsPage();
          resolve("SAFE");
          return;
        }
        
        performAnalysis();
      });
    } else {
      performAnalysis();
    }
    
    function performAnalysis() {
      var analysisPrompt = 'You are analyzing a webpage to determine if clicking "' + (buttonText || 'this button') + '" could be risky for the user.\n\n' +
        'ONLY mark as RISKY if you find CLEAR evidence of:\n' +
        '- Hidden subscription fees or auto-renewal charges\n' +
        '- Deceptive "free trial" that requires payment info and auto-charges\n' +
        '- Misleading pricing (showing lower price but charging more)\n' +
        '- Extremely difficult cancellation policies\n' +
        '- Unusually broad data collection beyond the service offered\n' +
        '- Clear scam indicators or fraudulent behavior\n\n' +
        'Mark as SAFE if:\n' +
        '- Normal legitimate website (news, shopping, services)\n' +
        '- Standard terms of service\n' +
        '- Regular signup/login forms\n' +
        '- Normal e-commerce checkout\n' +
        '- Educational or informational content\n' +
        '- No clear evidence of deceptive practices\n\n' +
        'Webpage content:\n' + text.slice(0, 2000) + '\n\n' +
        'Respond with only "RISKY" or "SAFE". Default to SAFE unless you find clear evidence of deceptive practices.';

      fetch("https://api.groq.com/openai/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + apiKey
        },
        body: JSON.stringify({
          model: "llama-3.1-8b-instant",
          messages: [
            {
              role: "system", 
              content: "You are a consumer protection assistant. You help users identify genuinely deceptive or fraudulent practices. You should only warn about CLEAR and OBVIOUS risks, not normal business practices. Err on the side of marking things as SAFE unless there's clear evidence of deception."
            },
            {
              role: "user",
              content: analysisPrompt
            }
          ],
          temperature: 0.2,
          max_tokens: 5,
          top_p: 0.9
        })
      })
      .then(function(response) {
        if (!response.ok) {
          throw new Error("API error: " + response.status + " " + response.statusText);
        }
        return response.json();
      })
      .then(function(data) {
        var analysis = (data.choices && data.choices[0] && data.choices[0].message && data.choices[0].message.content) ? 
                      data.choices[0].message.content.trim().toUpperCase() : "SAFE";
        
        console.log("API Analysis result:", analysis);
        
        var result = analysis.indexOf("RISKY") !== -1 ? "RISKY" : "SAFE";
        resolve(result);
      })
      .catch(function(error) {
        console.error("Groq API error:", error);
        resolve("SAFE");
      });
    }
  });
}

loadApiKey();