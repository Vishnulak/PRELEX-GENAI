# Informed Consent (IC) — Risk-Aware Action Guard (Chrome extension)

## What it does
This extension watches for critical action buttons on webpages (Accept Terms, Subscribe, Make Payment, Buy Now, Confirm, Start Trial...) and intercepts the click to analyze surrounding content. It sends the page context to a model (Groq API) you configure and receives a structured analysis containing a short summary, list of risks, and a detailed explanation. The extension shows an easy-to-understand dialog before letting the user proceed.

## Installation (developer mode)
1. Download the `IC.zip` and extract.
2. Open Chrome → Extensions → Toggle **Developer mode** on.
3. Click **Load unpacked** and select the extracted `IC` folder.
4. Open the extension Options page and paste your Groq API key and optionally your endpoint.
5. Visit any page and try clicking "Accept", "Subscribe", "Pay now", etc.

## Files
- `manifest.json` - extension manifest (MV3)
- `background.js` - service worker that calls Groq
- `content.js` - content script that intercepts clicks and shows modal
- `modal.css` - modal styles
- `options.html` / `options.js` - options page to store your Groq API key
- `icons/` - placeholder icons (you may replace them)

## Security & privacy notes
- The extension will send snippets of page text and form metadata to a third-party analysis service. Do NOT use the extension with highly confidential pages (banking, confidential portals) unless you trust the model endpoint.
- Your API key is stored using `chrome.storage.sync`. Consider the privacy implications.
- This code is provided as-is. Review it before installing.

## Customization & extension
- Improve the trigger patterns in `content.js`.
- Adjust prompt in `background.js` to match your Groq model prompt format.
- Add domain allow-list/deny-list in options to block sending sensitive domains.

## Disclaimer
This extension assists with highlighting potential risks but is not legal advice. Always read full agreements before consenting.
