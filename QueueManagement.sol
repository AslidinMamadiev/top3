// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title QueueManagement
 * @dev Shifoxonada navbat olish uchun smart-kontrakt
 * Payable funksiyalar, address tekshirish, mapping balanslar bilan
 */
contract QueueManagement {
    
    // Kontract egasi
    address public owner;
    
    // Minimal to'lov miqdori (wei da)
    uint256 public minimumPayment = 0.01 ether;
    
    // Ruxsat etilgan adres (faqat bu adresdan to'lov qabul qilamiz)
    address public allowedAddress;
    
    // Boshqa adres (to'lovni o'tkazamiz)
    address public recipientAddress;
    
    // Foydalanuvchi balansini saqlash (mapping)
    mapping(address => uint256) public userBalance;
    
    // Jami to'lovlar
    uint256 public totalPayments;
    
    // Events
    event PaymentReceived(address indexed payer, uint256 amount, string status);
    event FundsTransferred(address indexed recipient, uint256 amount);
    event WithdrawalMade(address indexed owner, uint256 amount);
    event BalanceUpdated(address indexed user, uint256 newBalance);
    
    /**
     * @dev Konstruktor - kontraktni o'rnatish
     * @param _allowedAddress Faqat bu adresdan to'lov qo'llanadi
     * @param _recipientAddress To'lovni bu adresga o'tkazamiz
     */
    constructor(address _allowedAddress, address _recipientAddress) {
        owner = msg.sender;
        allowedAddress = _allowedAddress;
        recipientAddress = _recipientAddress;
    }
    
    /**
     * @dev Payable funksiya - to'lov qabul qilish
     * - Faqat ma'lum adresdan qabul qilish
     * - Minimal miqdor tekshirish
     * - balans yangilash
     * - to'lovni boshqa adresga o'tkazish
     */
    function receivePayment() public payable {
        // Shart 1: Faqat ruxsat etilgan adresdan to'lov qabul qilish
        require(msg.sender == allowedAddress, "Siz to'lov jo'natishga ruxsat yo'q!");
        
        // Shart 2: Minimal to'lov miqdorini tekshirish
        require(msg.value >= minimumPayment, "To'lov miqdori juda kam!");
        
        // if/else yordamida turli holatlarda turli tranzaksiyalar
        if (msg.value >= 1 ether) {
            // Katta to'lov
            userBalance[msg.sender] += msg.value;
            totalPayments += msg.value;
            
            // To'lovni boshqa adresga o'tkazish
            (bool success, ) = payable(recipientAddress).call{value: msg.value}("");
            require(success, "To'lov o'tkazma amalga oshmadi!");
            
            emit PaymentReceived(msg.sender, msg.value, "Katta to'lov - Ruxsat berildi");
            emit BalanceUpdated(msg.sender, userBalance[msg.sender]);
            emit FundsTransferred(recipientAddress, msg.value);
        } 
        else if (msg.value >= 0.1 ether) {
            // O'rtacha to'lov
            uint256 fee = msg.value / 10; // 10% komissiya
            uint256 netAmount = msg.value - fee;
            
            userBalance[msg.sender] += netAmount;
            userBalance[owner] += fee;
            totalPayments += msg.value;
            
            // To'lovni boshqa adresga o'tkazish (komissiya o'chirgan holda)
            (bool success, ) = payable(recipientAddress).call{value: netAmount}("");
            require(success, "To'lov o'tkazma amalga oshmadi!");
            
            emit PaymentReceived(msg.sender, msg.value, "O'rtacha to'lov - Komissiya o'chirildi");
            emit BalanceUpdated(msg.sender, userBalance[msg.sender]);
            emit FundsTransferred(recipientAddress, netAmount);
        } 
        else {
            // Kichik to'lov
            userBalance[msg.sender] += msg.value;
            totalPayments += msg.value;
            
            // To'lovni boshqa adresga o'tkazish
            (bool success, ) = payable(recipientAddress).call{value: msg.value}("");
            require(success, "To'lov o'tkazma amalga oshmadi!");
            
            emit PaymentReceived(msg.sender, msg.value, "Kichik to'lov - Ruxsat berildi");
            emit BalanceUpdated(msg.sender, userBalance[msg.sender]);
            emit FundsTransferred(recipientAddress, msg.value);
        }
    }
    
    /**
     * @dev Faqat kontrakt egasi pul yechib olishi mumkin
     * @param amount Yechib olinadigan summa
     */
    function ownerWithdraw(uint256 amount) public {
        // Faqat kontrakt egasi yechib olishi mumkin
        require(msg.sender == owner, "Siz kontrakt egasi emassiz!");
        
        // Kontrakt balansini tekshirish
        require(address(this).balance >= amount, "Kontrakt balansida yetarli pul yo'q!");
        
        // Pul yechish
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Pul yechish amalga oshmadi!");
        
        emit WithdrawalMade(owner, amount);
    }
    
    /**
     * @dev Foydalanuvchi balansini olish
     * @param user Foydalanuvchining address
     */
    function getBalance(address user) public view returns (uint256) {
        return userBalance[user];
    }
    
    /**
     * @dev Kontrakt balansini olish
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Ruxsat etilgan adresni o'zgartirish
     * @param newAddress Yangi ruxsat qilingan address
     */
    function setAllowedAddress(address newAddress) public {
        require(msg.sender == owner, "Faqat kontrakt egasi o'zgartira oladi!");
        require(newAddress != address(0), "Noto'g'ri address!");
        allowedAddress = newAddress;
    }
    
    /**
     * @dev Qabul qiluvchi adresni o'zgartirish
     * @param newAddress Yangi qabul qiluvchi address
     */
    function setRecipientAddress(address newAddress) public {
        require(msg.sender == owner, "Faqat kontrakt egasi o'zgartira oladi!");
        require(newAddress != address(0), "Noto'g'ri address!");
        recipientAddress = newAddress;
    }
    
    /**
     * @dev Minimal to'lovni o'zgartirish
     * @param newMinimum Yangi minimal to'lov
     */
    function setMinimumPayment(uint256 newMinimum) public {
        require(msg.sender == owner, "Faqat kontrakt egasi o'zgartira oladi!");
        minimumPayment = newMinimum;
    }
    
    /**
     * @dev Fallback funksiya - to'lov qabul qilish
     */
    receive() external payable {
        // Avtomatik receivePayment chaqirish
        if (msg.sender == allowedAddress && msg.value >= minimumPayment) {
            // To'lov qo'llanadi
            userBalance[msg.sender] += msg.value;
            totalPayments += msg.value;
            
            (bool success, ) = payable(recipientAddress).call{value: msg.value}("");
            require(success, "To'lov o'tkazma amalga oshmadi!");
            
            emit PaymentReceived(msg.sender, msg.value, "Fallback to'lov");
            emit BalanceUpdated(msg.sender, userBalance[msg.sender]);
        }
    }
}
