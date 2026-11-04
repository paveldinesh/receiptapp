"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseReceiptFlow = void 0;
const genkit_config_js_1 = require("../genkit.config.js");
const receipt_schema_js_1 = require("../schemas/receipt.schema.js");
exports.parseReceiptFlow = genkit_config_js_1.ai.defineFlow({
    name: 'parseReceiptFlow',
    inputSchema: receipt_schema_js_1.ReceiptInputSchema,
    outputSchema: receipt_schema_js_1.ParsedReceiptSchema,
}, async (input) => {
    const promptInstructions = `
Analyze the provided bill receipt (image or text) and extract clean, structured accounting data.
Follow these extraction rules carefully:
1. Identify the merchant/store name accurately.
2. Categorize into one of: Electronics, Food, Grocery, Fashion, Travel, Health, Utilities, Other.
3. Extract total amount, subtotal, tax/GST, currency symbol/code, purchase date (YYYY-MM-DD), and payment method.
4. List all individual purchased items/products with quantity and total price per item.
5. If invoice number or warranty information (months) is present, extract it.
6. Provide an extraction confidence score between 0.0 and 1.0 based on clarity.
    `.trim();
    const parts = [
        { text: promptInstructions },
    ];
    if (input.ocrText && input.ocrText.trim().length > 0) {
        parts.push({
            text: `\n\nOCR Raw Text extracted from receipt:\n${input.ocrText}`,
        });
    }
    if (input.imageBase64 && input.imageBase64.trim().length > 0) {
        let base64Data = input.imageBase64.trim();
        const mimeType = input.mimeType || 'image/jpeg';
        // If data URL prefix is missing, format properly
        if (!base64Data.startsWith('data:')) {
            base64Data = `data:${mimeType};base64,${base64Data}`;
        }
        parts.push({
            media: {
                url: base64Data,
            },
        });
    }
    if (parts.length === 1 && !input.ocrText && !input.imageBase64) {
        throw new Error('Either imageBase64 or ocrText must be provided in request payload.');
    }
    const response = await genkit_config_js_1.ai.generate({
        prompt: parts,
        output: {
            schema: receipt_schema_js_1.ParsedReceiptSchema,
        },
    });
    if (!response.output) {
        throw new Error('Failed to generate structured receipt output from Gemini model.');
    }
    return response.output;
});
