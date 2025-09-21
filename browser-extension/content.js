// content.js
(function() {
  var TRIGGER_PATTERNS = [
    /accept.*terms/i, /agree.*terms/i, /subscribe/i, /sign up/i, 
    /register/i, /payment/i, /pay now/i, /buy now/i, /confirm.*purchase/i, 
    /start.*trial/i, /free.*trial/i, /billing/i, /checkout/i
  ];

  var processedButtons = new WeakSet();

  function isRiskButton(el) {
    if (!el) {
      return false;
    }
    
    var text = (el.innerText || el.value || el.getAttribute('aria-label') || el.title || '').trim();
    var isSubmitType = el.type === 'submit' || el.type === 'button';
    
    var matchesPattern = false;
    var i;
    for (i = 0; i < TRIGGER_PATTERNS.length; i++) {
      if (TRIGGER_PATTERNS[i].test(text)) {
        matchesPattern = true;
        break;
      }
    }
    
    return text && (matchesPattern || isSubmitType);
  }

  function gatherContext() {
    var snippetLimit = 2000;
    var context = '';
    
    var forms = document.querySelectorAll('form');
    var pricing = document.querySelectorAll('.price, .pricing, .cost, .fee, .charge, [class*="price"], [class*="cost"]');
    var terms = document.querySelectorAll('.terms, .agreement, .policy, [class*="terms"], [class*="policy"]');
    
    var relevantText = '';
    var i;
    
    for (i = 0; i < forms.length; i++) {
      relevantText += ' ' + (forms[i].innerText || '');
    }
    
    for (i = 0; i < pricing.length; i++) {
      relevantText += ' ' + (pricing[i].innerText || '');
    }
    
    for (i = 0; i < terms.length; i++) {
      relevantText += ' ' + (terms[i].innerText || '');
    }
    
    if (relevantText.trim().length < 200) {
      relevantText = document.body ? document.body.innerText : '';
    }
    
    context = relevantText.slice(0, snippetLimit);
    return context.trim();
  }

  function analyzeButton(button) {
    if (processedButtons.has(button)) {
      return;
    }
    processedButtons.add(button);
    
    button.style.opacity = '0.7';
    
    var context = gatherContext();
    console.log('Analyzing context length:', context.length);
    
    if (!chrome.runtime || !chrome.runtime.id) {
      console.log('Extension context invalidated, skipping analysis');
      button.style.opacity = '1';
      return;
    }
    
    chrome.runtime.sendMessage({ 
      action: "analyzeText", 
      text: context,
      buttonText: button.innerText || button.value || 'button'
    }, function(response) {
      button.style.opacity = '1';
      
      if (chrome.runtime.lastError) {
        console.error('Runtime error:', chrome.runtime.lastError.message);
        button.classList.add("ic-safe");
        return;
      }
      
      if (response && response.result === "RISKY") {
        console.log('Button marked as RISKY:', button);
        button.classList.add("ic-risky");
        button.classList.remove("ic-safe");
      } else {
        console.log('Button marked as SAFE:', button);
        button.classList.add("ic-safe");
        button.classList.remove("ic-risky");
      }
    });
  }

  function scanAndAnalyze() {
    var buttons = document.querySelectorAll("button, input[type=submit], input[type=button], [role=button]");
    console.log('Found buttons:', buttons.length);
    
    var i;
    for (i = 0; i < buttons.length; i++) {
      var btn = buttons[i];
      if (isRiskButton(btn) && !processedButtons.has(btn)) {
        console.log('Processing button:', btn.innerText || btn.value);
        (function(button) {
          setTimeout(function() { 
            analyzeButton(button); 
          }, Math.random() * 1000);
        })(btn);
      }
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', scanAndAnalyze);
  } else {
    scanAndAnalyze();
  }

  setTimeout(scanAndAnalyze, 2000);

  var timeoutId;
  var observer = new MutationObserver(function() {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(scanAndAnalyze, 500);
  });

  if (document.body) {
    observer.observe(document.body, { 
      childList: true, 
      subtree: true,
      attributes: true,
      attributeFilter: ['class', 'id']
    });
  }
})();