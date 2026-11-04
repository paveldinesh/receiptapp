"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReceiptInputSchema = exports.ParsedReceiptSchema = exports.ReceiptItemSchema = exports.PaymentMethodSchema = exports.ReceiptCategorySchema = void 0;
const zod_1 = require("zod");
exports.ReceiptCategorySchema = zod_1.z.enum([
    'Electronics',
    'Food',
    'Grocery',
    'Fashion',
    'Travel',
    'Health',
    'Utilities',
    'Other',
]);
exports.PaymentMethodSchema = zod_1.z.enum([
    'Credit Card',
    'Debit Card',
    'UPI',
    'Cash',
    'Other',
]);
exports.ReceiptItemSchema = zod_1.z.object({
    name: zod_1.z.string().describe('Name or description of the product/item'),
    quantity: zod_1.z.number().default(1).describe('Quantity purchased'),
    unitPrice: zod_1.z.number().optional().describe('Individual unit price if available'),
    price: zod_1.z.number().describe('Total price for this line item'),
});
exports.ParsedReceiptSchema = zod_1.z.object({
    merchant: zod_1.z.string().describe('Store, business, or merchant name'),
    category: exports.ReceiptCategorySchema.describe('Category of expenditure'),
    purchaseDate: zod_1.z.string().describe('Date of purchase in YYYY-MM-DD format'),
    currency: zod_1.z.string().default('₹').describe('Currency symbol or ISO code'),
    subtotal: zod_1.z.number().describe('Subtotal amount before taxes'),
    tax: zod_1.z.number().describe('Total tax or GST amount'),
    totalAmount: zod_1.z.number().describe('Final total bill amount paid'),
    paymentMethod: exports.PaymentMethodSchema.describe('Method of payment used'),
    invoiceNumber: zod_1.z.string().optional().describe('Invoice number or receipt serial number if present'),
    warrantyMonths: zod_1.z.number().optional().describe('Warranty period in months if identifiable'),
    products: zod_1.z.array(exports.ReceiptItemSchema).describe('List of itemized products or services'),
    summary: zod_1.z.string().optional().describe('Short 1-sentence summary of the bill receipt'),
    confidenceScore: zod_1.z.number().min(0).max(1).describe('Extraction confidence score between 0 and 1'),
});
exports.ReceiptInputSchema = zod_1.z.object({
    imageBase64: zod_1.z.string().optional().describe('Base64 encoded string of receipt image'),
    mimeType: zod_1.z.string().optional().default('image/jpeg').describe('MIME type of the image (e.g. image/jpeg, image/png)'),
    ocrText: zod_1.z.string().optional().describe('Raw OCR text if text extraction was pre-computed'),
});
