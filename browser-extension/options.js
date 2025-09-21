// options.js
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('settings-form');
    const apiKeyInput = document.getElementById('api-key');
    const statusDiv = document.getElementById('status');

    // Load saved settings
    chrome.storage.sync.get(['groqApiKey'], function(result) {
        if (result.groqApiKey) {
            apiKeyInput.value = result.groqApiKey;
        }
    });

    // Save settings
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        const apiKey = apiKeyInput.value.trim();
        
        if (!apiKey) {
            showStatus('Please enter an API key', 'error');
            return;
        }

        if (!apiKey.startsWith('gsk_')) {
            showStatus('Invalid Groq API key format. Keys should start with "gsk_"', 'error');
            return;
        }

        chrome.storage.sync.set({
            groqApiKey: apiKey
        }, function() {
            if (chrome.runtime.lastError) {
                showStatus('Error saving settings: ' + chrome.runtime.lastError.message, 'error');
            } else {
                showStatus('Settings saved successfully!', 'success');
                // Notify background script to reload the API key
                chrome.runtime.sendMessage({action: "reloadConfig"});
            }
        });
    });

    function showStatus(message, type) {
        statusDiv.textContent = message;
        statusDiv.className = 'status ' + type;
        statusDiv.style.display = 'block';
        
        setTimeout(() => {
            statusDiv.style.display = 'none';
        }, 3000);
    }
});