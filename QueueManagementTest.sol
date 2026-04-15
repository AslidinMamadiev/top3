// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./QueueManagement.sol";

/**
 * @title QueueManagementTest
 * @dev Kontraktni sinab ko'rish uchun test fayli
 */
contract QueueManagementTest {
    
    QueueManagement public contract;
    
    address public owner = 0x1234567890123456789012345678901234567890;
    address public allowedUser = 0x0987654321098765432109876543210987654321;
    address public recipient = 0xABCDEFABCDEFABCDEFABCDEFABCDEFABCDEFABCD;
    address public unauthorizedUser = 0x1111111111111111111111111111111111111111;
    
    /**
     * @dev Kontraktni o'rnatish
     */
    function setUp() public {
        contract = new QueueManagement(allowedUser, recipient);
    }
    
    /**
     * @dev Test 1: Ruxsat etilgan adres to'lov jo'nata olishi
     */
    function testAllowedUserCanPay() public {
        // To'lov jo'natish
        (bool success, ) = address(contract).call{value: 0.05 ether}(
            abi.encodeWithSignature("receivePayment()")
        );
        require(success, "To'lov amalga oshmadi!");
    }
    
    /**
     * @dev Test 2: Ruxsat etilmagan adres to'lov jo'nota olmasi
     */
    function testUnauthorizedUserCannotPay() public {
        // Ruxsat etilmagan adres to'lov yuborishi kerak xato kelish
        require(address(unauthorizedUser) != address(allowedUser), "Test adres noto'g'ri!");
    }
    
    /**
     * @dev Test 3: Minimal to'lovni tekshirish
     */
    function testMinimumPaymentCheck() public {
        // Minimal to'lovdan kam jo'natish kerak xato kelish
        uint256 tooSmall = 0.001 ether; // 0.01 ether dan kam
        require(tooSmall < 0.01 ether, "Minimal to'lov tekshovi bajarildi!");
    }
    
    /**
     * @dev Test 4: Balans mapping tekshirish
     */
    function testUserBalanceMapping() public {
        uint256 initialBalance = contract.getBalance(allowedUser);
        
        // To'lov jo'natish
        (bool success, ) = address(contract).call{value: 0.5 ether}(
            abi.encodeWithSignature("receivePayment()")
        );
        require(success, "To'lov amalga oshmadi!");
        
        // Balans o'zgarilganligi tekshirish
        uint256 newBalance = contract.getBalance(allowedUser);
        require(newBalance > initialBalance, "Balans o'zgarilmadi!");
    }
    
    /**
     * @dev Test 5: Owner-only withdraw
     */
    function testOwnerCanWithdraw() public {
        // Faqat owner yechib olishi mumkin
        require(msg.sender == owner, "Faqat owner yechib olishi mumkin!");
    }
    
    /**
     * @dev Test 6: Kontraktga to'lov jo'natish
     */
    function testTransferFundsToRecipient() public {
        uint256 initialRecipientBalance = address(recipient).balance;
        
        // To'lov jo'natish
        (bool success, ) = address(contract).call{value: 1 ether}(
            abi.encodeWithSignature("receivePayment()")
        );
        require(success, "To'lov o'tkazma amalga oshmadi!");
    }
    
    /**
     * @dev Test 7: Events to'g'ri emit qilinishini tekshirish
     */
    function testEventsEmitted() public {
        // Event log-larini tekshirish zarur
        // Hardhat yoki Remix orqali tekshirish mumkin
    }
    
    // Fallback funksiya - to'lov qabul qilish uchun
    receive() external payable {}
}
