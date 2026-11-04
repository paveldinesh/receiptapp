# ReceiptVault Genkit Backend Server

A Node.js TypeScript server powered by **Firebase Genkit** and **Google Gemini** models to process bill receipts (images or OCR text) and extract clean, structured accounting data.

---

## 🚀 Features

- **Multimodal Receipt Parsing**: Accepts receipt images (JPEG/PNG/WebP/PDF) or raw OCR text.
- **Structured Output**: Uses Zod schemas to guarantee consistent JSON response containing:
  - Merchant Name & Category
  - Subtotal, Tax, Total Amount, and Currency
  - Purchase Date & Payment Method
  - Itemized List of Products (Name, Quantity, Unit Price, Total Price)
  - Invoice Number & Warranty Period
  - Extraction Confidence Score
- **Multiple API Formats**:
  - **Multipart File Upload** (`multipart/form-data`)
  - **Base64 JSON Payload** (`application/json`)
  - **OCR Text Payload**

---

## 🛠️ Prerequisites

- **Node.js** (v18 or higher recommended)
- **npm** or **yarn**
- **Gemini API Key** from [Google AI Studio](https://aistudio.google.com/)

---

## ⚙️ Installation & Setup

1. **Navigate to the genKit directory**:
   ```bash
   cd genKit
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Configure Environment Variables**:
   Copy `.env.example` to `.env` and enter your Gemini API Key:
   ```bash
   cp .env.example .env
   ```
   Edit `.env`:
   ```env
   PORT=3000
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   ```

---

## 🏃 Running the Server

### Development Mode (Auto-reload)
```bash
npm run dev
```

### Production Build & Start
```bash
npm run build
npm start
```

### Developer UI (Genkit Inspector)
```bash
npm run genkit:start
```

---

## 📡 API Endpoints

### 1. Health Check
- **URL**: `GET /health`
- **Response**:
  ```json
  {
    "status": "ok",
    "service": "ReceiptVault Genkit Server",
    "timestamp": "2026-07-29T07:30:00.000Z"
  }
  ```

---

### 2. Parse Receipt
- **URL**: `POST /api/parse-receipt`

#### Option A: File Upload (`multipart/form-data`)
Attach receipt image file under field name `receipt` or `file`.

```bash
curl -X POST http://localhost:3000/api/parse-receipt \
  -F "receipt=@/path/to/receipt_sample.jpg"
```

#### Option B: Base64 JSON Payload (`application/json`)
```bash
curl -X POST http://localhost:3000/api/parse-receipt \
  -H "Content-Type: application/json" \
  -d '{
    "imageBase64": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
    "mimeType": "image/jpeg"
  }'
```

#### Option C: Raw OCR Text Payload
```bash
curl -X POST http://localhost:3000/api/parse-receipt \
  -H "Content-Type: application/json" \
  -d '{
    "ocrText": "WALMART STORE #1234\nDate: 2026-07-28\nMilk $3.50\nBread $2.00\nTAX $0.44\nTOTAL $5.94\nPaid via Credit Card"
  }'
```

---

## 📄 Response Format

```json
{
  "success": true,
  "data": {
    "merchant": "Walmart Store #1234",
    "category": "Grocery",
    "purchaseDate": "2026-07-28",
    "currency": "$",
    "subtotal": 5.5,
    "tax": 0.44,
    "totalAmount": 5.94,
    "paymentMethod": "Credit Card",
    "invoiceNumber": "1234",
    "warrantyMonths": 0,
    "products": [
      {
        "name": "Milk",
        "quantity": 1,
        "price": 3.5
      },
      {
        "name": "Bread",
        "quantity": 1,
        "price": 2.0
      }
    ],
    "summary": "Grocery purchase from Walmart Store #1234 for $5.94.",
    "confidenceScore": 0.98
  }
}
```

---

## 📱 Flutter Client Integration Example

In your Flutter app (`receiptvault_flutter`), you can send an image directly:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> sendReceiptToGenkitServer(File imageFile) async {
  final uri = Uri.parse('http://YOUR_SERVER_IP:3000/api/parse-receipt');
  final request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('receipt', imageFile.path));

  final response = await request.send();
  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final jsonResult = jsonDecode(responseBody);
    if (jsonResult['success'] == true) {
      return jsonResult['data'];
    }
  }
  return null;
}
```
