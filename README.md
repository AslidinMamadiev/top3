# QueueManagement Smart Contract - Ishlash Qo'llanmasi

## Tavsif
Bu Solidity smart-kontrakti shifoxonada navbat olish tizimida to'lovlarni boshqarish uchun mo'ljallangan.

## Asosiy Xususiyatlar

### 1. **Payable Funksiya - `receivePayment()`**
- Etherium qabul qila oladi
- Faqat ma'lum adresdan (`allowedAddress`) to'lov qabul qiladi
- Minimal to'lov miqdorini tekshiradi

### 2. **Address Tekshirish**
- `require(msg.sender == allowedAddress, "...")` - Faqat ruxsat qilingan adresdan to'lov
- Kimga ayni to'lovni o'tkazish (`recipientAddress`)

### 3. **Minimal To'lov (Require)**
```solidity
require(msg.value >= minimumPayment, "To'lov miqdori juda kam!");
```

### 4. **If/Else - Turli Holatlarda Turli Tranzaksiyalar**
- **Katta to'lov** (≥ 1 ether): To'lovni to'liq o'tkazish
- **O'rtacha to'lov** (≥ 0.1 ether): 10% komissiya o'chirish
- **Kichik to'lov**: To'lovni to'liq o'tkazish

### 5. **Mapping - Foydalanuvchi Balansini Saqlash**
```solidity
mapping(address => uint256) public userBalance;
```
Har bir foydalanuvchining balansini saqlaydi.

### 6. **Owner-Only Withdraw Funksiyasi**
```solidity
function ownerWithdraw(uint256 amount) public
```
Faqat kontrakt egasi (`owner`) pul yechib olishi mumkin.

### 7. **Events - To'lov Sharoitida Emit**
```
- PaymentReceived: To'lov qo'llanilganda
- FundsTransferred: Pul o'tkazilganda
- WithdrawalMade: Yechish amalga oshganda
- BalanceUpdated: Balans o'zgarilganda
```

## Kontraktni Deployment Qilish

### Parametrlar:
```solidity
constructor(
    address _allowedAddress,      // Faqat bu adresdan to'lov qabul qil
    address _recipientAddress     // To'lovni bu adresga o'tkazish
)
```

### Misol:
```
Allowed Address: 0x123...  (To'lovni yuboruvchi)
Recipient Address: 0x456... (To'lovni qabul qiluvchi)
Minimum Payment: 0.01 ether (10 Finney)
```

## Asosiy Funksiyalar

| Funksiya | Tavsif |
|----------|--------|
| `receivePayment()` | To'lov qabul qilish (payable) |
| `ownerWithdraw(amount)` | Egasi pul yechib olishi |
| `getBalance(user)` | Foydalanuvchi balansini ko'rish |
| `getContractBalance()` | Kontrakt balansini ko'rish |
| `setAllowedAddress(address)` | Ruxsat qilingan adresni o'zgartirish |
| `setRecipientAddress(address)` | Qabul qiluvchi adresni o'zgartirish |
| `setMinimumPayment(amount)` | Minimal to'lovni o'zgartirish |

## Xavfsizlik Transkriptlari (Require Statements)

✅ **User (Foydalanuvchi) Tekshirish:**
- Faqat `allowedAddress` dan to'lov qabul qilish
- To'lov minimal summan dan kam bo'lmasi

✅ **Owner (Egasi) Tekshirish:**
- Faqat owner `ownerWithdraw()` chaqira oladi
- Faqat owner address va recipient o'zgartira oladi

✅ **Balans Tekshirish:**
- Kontrakt balansida yetarli pul mavjudligi

## Ishlash Sxemasi

```
User (allowedAddress) 
    ↓
receivePayment() 
    ↓
✓ Address tekshov → ✓ Minimal to'lov tekshov
    ↓
if/else (to'lov miqdoriga qarab)
    ↓
mappingda balans yangilash
    ↓
Pul recipientAddress ga o'tkazish
    ↓
Event Emit (PaymentReceived, FundsTransferred, BalanceUpdated)
```

## Foydalanish Misoli (Web3.js)

```javascript
// Kontraktni yuklash (ABI va Address kerak)
const contract = new web3.eth.Contract(ABI, contractAddress);

// Ruxsat qilingan adresdan to'lov jo'natish
await contract.methods.receivePayment()
    .send({ 
        from: allowedAddress, 
        value: web3.utils.toWei("0.5", "ether") 
    });

// Balansni tekshirish
const balance = await contract.methods.getBalance(allowedAddress).call();
console.log("Balans:", balance);

// Owner - Pul yechish
await contract.methods.ownerWithdraw(web3.utils.toWei("1", "ether"))
    .send({ from: ownerAddress });
```

## Muhim E'tiroznomalar ⚠️

1. Kontraktni noyob test tarmoqlarda (Testnet) sinab ko'rish
2. Haqiqiy ishlatishdan oldin audit o'tkazish
3. Private keys ni hech qachon ulashmaslik
4. Gas xarajini hisobga olish

---
**Version:** 1.0  
**Lisenziya:** MIT  
**Solidity Version:** ^0.8.0
