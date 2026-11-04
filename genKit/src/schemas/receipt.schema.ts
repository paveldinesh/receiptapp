import { z } from 'zod';

export const ReceiptCategorySchema = z.enum([
  'Electronics',
  'Food',
  'Grocery',
  'Fashion',
  'Travel',
  'Health',
  'Utilities',
  'Other',
]);

export const PaymentMethodSchema = z.enum([
  'Credit Card',
  'Debit Card',
  'UPI',
  'Cash',
  'Other',
]);

export const ReceiptItemSchema = z.object({
  name: z.string().describe('Name or description of the product/item'),
  quantity: z.number().default(1).describe('Quantity purchased'),
  unitPrice: z.number().optional().describe('Individual unit price if available'),
  price: z.number().describe('Total price for this line item'),
});

export const LineItemSchema = z.object({
  name: z.string().describe('Name or description of the product/item'),
  quantity: z.number().describe('Quantity purchased'),
  rate: z.number().describe('Unit price or rate'),
  amount: z.number().describe('Total amount for this line item'),
});

export const ParsedReceiptSchema = z.object({
  merchant: z.string().describe('Store, business, or merchant name'),
  category: ReceiptCategorySchema.describe('Category of expenditure'),
  purchaseDate: z.string().describe('Date of purchase in YYYY-MM-DD format'),
  currency: z.string().default('₹').describe('Currency symbol or ISO code'),
  subtotal: z.number().describe('Subtotal amount before taxes'),
  tax: z.number().describe('Total tax or GST amount'),
  totalAmount: z.number().describe('Final total bill amount paid'),
  paymentMethod: PaymentMethodSchema.describe('Method of payment used'),
  invoiceNumber: z.string().optional().describe('Invoice number or receipt serial number if present'),
  warrantyMonths: z.number().optional().describe('Warranty period in months if identifiable'),
  products: z.array(ReceiptItemSchema).describe('List of itemized products or services'),
  line_items: z.array(LineItemSchema).default([]).describe('Line items with name, quantity, rate, amount'),
  summary: z.string().optional().describe('Short 1-sentence summary of the bill receipt'),
  confidenceScore: z.number().min(0).max(1).describe('Extraction confidence score between 0 and 1'),
});

export const ReceiptInputSchema = z.object({
  imageBase64: z.string().optional().describe('Base64 encoded string of receipt image'),
  mimeType: z.string().optional().default('image/jpeg').describe('MIME type of the image (e.g. image/jpeg, image/png)'),
  ocrText: z.string().optional().describe('Raw OCR text if text extraction was pre-computed'),
});

export type ParsedReceipt = z.infer<typeof ParsedReceiptSchema>;
export type ReceiptInput = z.infer<typeof ReceiptInputSchema>;
