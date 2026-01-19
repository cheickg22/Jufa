package ml.jufa.backend.agent.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.agent.dto.*;
import ml.jufa.backend.agent.entity.*;
import ml.jufa.backend.agent.repository.*;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.notification.service.PushNotificationService;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.entity.UserType;
import ml.jufa.backend.user.repository.UserRepository;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;
import ml.jufa.backend.wallet.repository.WalletRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AgentService {

    private final AgentTransactionRepository transactionRepository;
    private final AgentCommissionRepository commissionRepository;
    private final AgentDailyReportRepository reportRepository;
    private final AgentProfileRepository agentProfileRepository;
    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final PushNotificationService pushNotificationService;
    private final PasswordEncoder passwordEncoder;

    private static final BigDecimal CASH_IN_FEE_PERCENT = new BigDecimal("0.01");
    private static final BigDecimal CASH_OUT_FEE_PERCENT = new BigDecimal("0.015");
    private static final BigDecimal AGENT_COMMISSION_RATE = new BigDecimal("0.70");
    private static final BigDecimal MIN_CASH_IN = new BigDecimal("100");
    private static final BigDecimal MAX_CASH_IN = new BigDecimal("5000000");
    private static final BigDecimal MIN_CASH_OUT = new BigDecimal("500");
    private static final BigDecimal MAX_CASH_OUT = new BigDecimal("2000000");

    @Transactional
    public AgentTransactionResponse processCashIn(User agent, CashInRequest request) {
        validateAgent(agent);
        validateCashInAmount(request.getAmount());

        User customer = userRepository.findByPhone(request.getCustomerPhone())
                .orElseThrow(() -> new JufaException("JUFA-AGENT-002", "Client non trouvé"));

        BigDecimal fee = calculateCashInFee(request.getAmount());
        BigDecimal agentCommission = calculateAgentCommission(fee);
        BigDecimal platformFee = fee.subtract(agentCommission);

        AgentTransaction transaction = AgentTransaction.builder()
                .reference(generateReference("CI"))
                .agent(agent)
                .customer(customer)
                .transactionType(AgentTransactionType.CASH_IN)
                .amount(request.getAmount())
                .fee(fee)
                .agentCommission(agentCommission)
                .platformFee(platformFee)
                .customerPhone(request.getCustomerPhone())
                .description(request.getDescription() != null ? request.getDescription() : "Dépôt cash via agent")
                .build();

        transactionRepository.save(transaction);

        Wallet customerWallet = getCustomerWallet(customer);
        Wallet lockedWallet = walletRepository.findWithLockById(customerWallet.getId())
                .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet client non trouvé"));

        BigDecimal netAmount = request.getAmount().subtract(fee);
        lockedWallet.credit(netAmount);
        walletRepository.save(lockedWallet);

        creditAgentCommission(agent, transaction, agentCommission);

        transaction.complete();
        transactionRepository.save(transaction);

        updateDailyReport(agent, transaction);

        pushNotificationService.sendTransactionReceived(customer, netAmount, "Agent", transaction.getReference());

        log.info("Cash-in completed: {} XOF for customer {} by agent {}", 
                request.getAmount(), customer.getPhone(), agent.getPhone());

        return AgentTransactionResponse.fromEntity(transaction);
    }

    @Transactional
    public AgentTransactionResponse processCashOut(User agent, CashOutRequest request) {
        validateAgent(agent);
        validateCashOutAmount(request.getAmount());

        User customer = userRepository.findByPhone(request.getCustomerPhone())
                .orElseThrow(() -> new JufaException("JUFA-AGENT-002", "Client non trouvé"));

        if (!passwordEncoder.matches(request.getCustomerPin(), customer.getPinHash())) {
            throw new JufaException("JUFA-AGENT-003", "PIN incorrect");
        }

        Wallet agentWallet = getAgentWallet(agent);
        BigDecimal fee = calculateCashOutFee(request.getAmount());
        BigDecimal agentCommission = calculateAgentCommission(fee);
        BigDecimal platformFee = fee.subtract(agentCommission);
        BigDecimal totalDebit = request.getAmount().add(fee);

        if (agentWallet.getAvailableBalance().compareTo(request.getAmount()) < 0) {
            throw new JufaException("JUFA-AGENT-004", "Solde agent insuffisant pour ce retrait");
        }

        Wallet customerWallet = getCustomerWallet(customer);
        if (customerWallet.getAvailableBalance().compareTo(totalDebit) < 0) {
            throw new JufaException("JUFA-AGENT-005", "Solde client insuffisant");
        }

        AgentTransaction transaction = AgentTransaction.builder()
                .reference(generateReference("CO"))
                .agent(agent)
                .customer(customer)
                .transactionType(AgentTransactionType.CASH_OUT)
                .amount(request.getAmount())
                .fee(fee)
                .agentCommission(agentCommission)
                .platformFee(platformFee)
                .customerPhone(request.getCustomerPhone())
                .description(request.getDescription() != null ? request.getDescription() : "Retrait cash via agent")
                .build();

        transactionRepository.save(transaction);

        Wallet lockedCustomerWallet = walletRepository.findWithLockById(customerWallet.getId())
                .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet client non trouvé"));
        lockedCustomerWallet.debit(totalDebit);
        walletRepository.save(lockedCustomerWallet);

        creditAgentCommission(agent, transaction, agentCommission);

        transaction.complete();
        transactionRepository.save(transaction);

        updateDailyReport(agent, transaction);

        pushNotificationService.sendTransactionSent(customer, request.getAmount(), "Agent", transaction.getReference());

        log.info("Cash-out completed: {} XOF for customer {} by agent {}", 
                request.getAmount(), customer.getPhone(), agent.getPhone());

        return AgentTransactionResponse.fromEntity(transaction);
    }

    public FeeCalculationResponse calculateCashInFees(BigDecimal amount) {
        BigDecimal fee = calculateCashInFee(amount);
        BigDecimal agentCommission = calculateAgentCommission(fee);
        return FeeCalculationResponse.builder()
                .amount(amount)
                .fee(fee)
                .totalAmount(amount)
                .agentCommission(agentCommission)
                .feeDescription("Frais de dépôt: 1%")
                .build();
    }

    public FeeCalculationResponse calculateCashOutFees(BigDecimal amount) {
        BigDecimal fee = calculateCashOutFee(amount);
        BigDecimal agentCommission = calculateAgentCommission(fee);
        return FeeCalculationResponse.builder()
                .amount(amount)
                .fee(fee)
                .totalAmount(amount.add(fee))
                .agentCommission(agentCommission)
                .feeDescription("Frais de retrait: 1.5%")
                .build();
    }

    public AgentDashboardResponse getDashboard(User agent) {
        validateAgent(agent);

        Wallet agentWallet = getAgentWallet(agent);
        Wallet commissionWallet = getCommissionWallet(agent);

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime weekStart = LocalDate.now().minusDays(7).atStartOfDay();
        LocalDateTime monthStart = LocalDate.now().withDayOfMonth(1).atStartOfDay();

        BigDecimal todayCashIn = transactionRepository.sumAmountByAgentAndTypeAndDateAfter(
                agent, AgentTransactionType.CASH_IN, todayStart);
        BigDecimal todayCashOut = transactionRepository.sumAmountByAgentAndTypeAndDateAfter(
                agent, AgentTransactionType.CASH_OUT, todayStart);
        BigDecimal todayVolume = (todayCashIn != null ? todayCashIn : BigDecimal.ZERO)
                .add(todayCashOut != null ? todayCashOut : BigDecimal.ZERO);

        long todayTx = transactionRepository.countCompletedByAgentAfter(agent, todayStart);
        long weekTx = transactionRepository.countCompletedByAgentAfter(agent, weekStart);
        long monthTx = transactionRepository.countCompletedByAgentAfter(agent, monthStart);

        BigDecimal todayCommission = transactionRepository.sumCommissionByAgentAfter(agent, todayStart);
        BigDecimal weekCommission = transactionRepository.sumCommissionByAgentAfter(agent, weekStart);
        BigDecimal monthCommission = transactionRepository.sumCommissionByAgentAfter(agent, monthStart);

        BigDecimal weekCashIn = transactionRepository.sumAmountByAgentAndTypeAndDateAfter(
                agent, AgentTransactionType.CASH_IN, weekStart);
        BigDecimal weekCashOut = transactionRepository.sumAmountByAgentAndTypeAndDateAfter(
                agent, AgentTransactionType.CASH_OUT, weekStart);
        BigDecimal weekVolume = (weekCashIn != null ? weekCashIn : BigDecimal.ZERO)
                .add(weekCashOut != null ? weekCashOut : BigDecimal.ZERO);

        BigDecimal monthCashIn = transactionRepository.sumAmountByAgentAndTypeAndDateAfter(
                agent, AgentTransactionType.CASH_IN, monthStart);
        BigDecimal monthCashOut = transactionRepository.sumAmountByAgentAndTypeAndDateAfter(
                agent, AgentTransactionType.CASH_OUT, monthStart);
        BigDecimal monthVolume = (monthCashIn != null ? monthCashIn : BigDecimal.ZERO)
                .add(monthCashOut != null ? monthCashOut : BigDecimal.ZERO);

        BigDecimal totalCommission = commissionRepository.sumTotalCommissionByAgent(agent);
        long pendingTx = transactionRepository.countByAgentAndStatus(agent, AgentTransactionStatus.PENDING);

        AgentProfile agentProfile = getOrCreateAgentProfile(agent);

        return AgentDashboardResponse.builder()
                .walletBalance(agentWallet.getBalance())
                .commissionBalance(commissionWallet != null ? commissionWallet.getBalance() : BigDecimal.ZERO)
                .todayVolume(todayVolume)
                .todayTransactions((int) todayTx)
                .todayCommission(todayCommission != null ? todayCommission : BigDecimal.ZERO)
                .todayDeposits(todayCashIn != null ? todayCashIn : BigDecimal.ZERO)
                .todayWithdrawals(todayCashOut != null ? todayCashOut : BigDecimal.ZERO)
                .weekVolume(weekVolume)
                .weekTransactions((int) weekTx)
                .weekCommission(weekCommission != null ? weekCommission : BigDecimal.ZERO)
                .monthVolume(monthVolume)
                .monthTransactions((int) monthTx)
                .monthCommission(monthCommission != null ? monthCommission : BigDecimal.ZERO)
                .totalCommissionEarned(totalCommission != null ? totalCommission : BigDecimal.ZERO)
                .pendingTransactions((int) pendingTx)
                .depositCommissionRate(agentProfile.getDepositCommissionRate())
                .withdrawalCommissionRate(agentProfile.getWithdrawalCommissionRate())
                .agentCode(agentProfile.getAgentCode())
                .fullName(agentProfile.getFullName())
                .hasSecretCode(agentProfile.hasSecretCode())
                .build();
    }

    public Page<AgentTransactionResponse> getTransactionHistory(User agent, Pageable pageable) {
        validateAgent(agent);
        return transactionRepository.findByAgentOrderByCreatedAtDesc(agent, pageable)
                .map(AgentTransactionResponse::fromEntity);
    }

    public Page<AgentTransactionResponse> getTransactionsByType(User agent, AgentTransactionType type, Pageable pageable) {
        validateAgent(agent);
        return transactionRepository.findByAgentAndTransactionTypeOrderByCreatedAtDesc(agent, type, pageable)
                .map(AgentTransactionResponse::fromEntity);
    }

    public List<AgentDailyReportResponse> getDailyReports(User agent, LocalDate startDate, LocalDate endDate) {
        validateAgent(agent);
        return reportRepository.findByAgentAndReportDateBetweenOrderByReportDateDesc(agent, startDate, endDate)
                .stream()
                .map(AgentDailyReportResponse::fromEntity)
                .toList();
    }

    public List<AgentDailyReportResponse> getLast30DaysReports(User agent) {
        validateAgent(agent);
        return reportRepository.findLast30DaysByAgent(agent)
                .stream()
                .map(AgentDailyReportResponse::fromEntity)
                .toList();
    }

    private void validateAgent(User user) {
        if (user.getUserType() != UserType.AGENT) {
            throw new JufaException("JUFA-AGENT-001", "Accès réservé aux agents");
        }
    }

    private void validateCashInAmount(BigDecimal amount) {
        if (amount.compareTo(MIN_CASH_IN) < 0) {
            throw new JufaException("JUFA-AGENT-006", "Montant minimum: " + MIN_CASH_IN + " XOF");
        }
        if (amount.compareTo(MAX_CASH_IN) > 0) {
            throw new JufaException("JUFA-AGENT-007", "Montant maximum: " + MAX_CASH_IN + " XOF");
        }
    }

    private void validateCashOutAmount(BigDecimal amount) {
        if (amount.compareTo(MIN_CASH_OUT) < 0) {
            throw new JufaException("JUFA-AGENT-006", "Montant minimum: " + MIN_CASH_OUT + " XOF");
        }
        if (amount.compareTo(MAX_CASH_OUT) > 0) {
            throw new JufaException("JUFA-AGENT-007", "Montant maximum: " + MAX_CASH_OUT + " XOF");
        }
    }

    private BigDecimal calculateCashInFee(BigDecimal amount) {
        return amount.multiply(CASH_IN_FEE_PERCENT).setScale(0, RoundingMode.CEILING);
    }

    private BigDecimal calculateCashOutFee(BigDecimal amount) {
        return amount.multiply(CASH_OUT_FEE_PERCENT).setScale(0, RoundingMode.CEILING);
    }

    private BigDecimal calculateAgentCommission(BigDecimal fee) {
        return fee.multiply(AGENT_COMMISSION_RATE).setScale(0, RoundingMode.FLOOR);
    }

    private Wallet getAgentWallet(User agent) {
        return walletRepository.findByUserAndWalletType(agent, WalletType.AGENT)
                .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet agent non trouvé"));
    }

    private Wallet getCommissionWallet(User agent) {
        return walletRepository.findByUserAndWalletType(agent, WalletType.COMMISSION)
                .orElse(null);
    }

    private Wallet getCustomerWallet(User customer) {
        WalletType walletType = switch (customer.getUserType()) {
            case MERCHANT -> WalletType.B2B;
            case AGENT -> WalletType.AGENT;
            default -> WalletType.B2C;
        };
        return walletRepository.findByUserAndWalletType(customer, walletType)
                .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet client non trouvé"));
    }

    private void creditAgentCommission(User agent, AgentTransaction transaction, BigDecimal commission) {
        Wallet commissionWallet = walletRepository.findByUserAndWalletType(agent, WalletType.COMMISSION)
                .orElseGet(() -> createCommissionWallet(agent));

        Wallet lockedCommissionWallet = walletRepository.findWithLockById(commissionWallet.getId())
                .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet commission non trouvé"));

        lockedCommissionWallet.credit(commission);
        walletRepository.save(lockedCommissionWallet);

        AgentCommission agentCommission = AgentCommission.builder()
                .agent(agent)
                .transaction(transaction)
                .commissionDate(LocalDate.now())
                .amount(commission)
                .commissionRate(AGENT_COMMISSION_RATE.multiply(new BigDecimal("100")))
                .description("Commission sur " + transaction.getTransactionType().getDisplayName())
                .build();
        agentCommission.credit();
        commissionRepository.save(agentCommission);
    }

    private Wallet createCommissionWallet(User agent) {
        Wallet wallet = Wallet.builder()
                .user(agent)
                .walletType(WalletType.COMMISSION)
                .currency("XOF")
                .build();
        return walletRepository.save(wallet);
    }

    private void updateDailyReport(User agent, AgentTransaction transaction) {
        LocalDate today = LocalDate.now();
        AgentDailyReport report = reportRepository.findByAgentAndReportDate(agent, today)
                .orElseGet(() -> AgentDailyReport.builder()
                        .agent(agent)
                        .reportDate(today)
                        .build());

        if (transaction.getTransactionType() == AgentTransactionType.CASH_IN) {
            report.addCashIn(transaction.getAmount(), transaction.getAgentCommission(), transaction.getFee());
        } else {
            report.addCashOut(transaction.getAmount(), transaction.getAgentCommission(), transaction.getFee());
        }

        reportRepository.save(report);
    }

    private String generateReference(String prefix) {
        return prefix + System.currentTimeMillis() + String.format("%04d", (int) (Math.random() * 10000));
    }

    public AgentProfileResponse getProfile(User agent) {
        validateAgent(agent);
        AgentProfile profile = getOrCreateAgentProfile(agent);
        return AgentProfileResponse.fromEntity(profile);
    }

    public boolean verifySecretCode(User agent, String secretCode) {
        validateAgent(agent);
        AgentProfile profile = agentProfileRepository.findByUser(agent)
                .orElseThrow(() -> new JufaException("JUFA-AGENT-010", "Profil agent non trouvé"));

        if (!profile.hasSecretCode()) {
            throw new JufaException("JUFA-AGENT-011", "Code secret non configuré");
        }

        return passwordEncoder.matches(secretCode, profile.getSecretCodeHash());
    }

    @Transactional
    public void updateSecretCode(User agent, String oldSecretCode, String newSecretCode) {
        validateAgent(agent);
        AgentProfile profile = getOrCreateAgentProfile(agent);

        if (profile.hasSecretCode()) {
            if (oldSecretCode == null || !passwordEncoder.matches(oldSecretCode, profile.getSecretCodeHash())) {
                throw new JufaException("JUFA-AGENT-012", "Ancien code secret incorrect");
            }
        }

        profile.setSecretCodeHash(passwordEncoder.encode(newSecretCode));
        agentProfileRepository.save(profile);
        log.info("Secret code updated for agent {}", agent.getPhone());
    }

    public ClientSearchResponse searchClient(User agent, String phone) {
        validateAgent(agent);

        User customer = userRepository.findByPhone(phone)
                .orElseThrow(() -> new JufaException("JUFA-AGENT-002", "Client non trouvé"));

        Wallet wallet = null;
        try {
            wallet = getCustomerWallet(customer);
        } catch (JufaException ignored) {
        }

        return ClientSearchResponse.fromUserAndWallet(customer, wallet);
    }

    private AgentProfile getOrCreateAgentProfile(User agent) {
        return agentProfileRepository.findByUser(agent)
                .orElseGet(() -> {
                    String agentCode = generateAgentCode();
                    AgentProfile profile = AgentProfile.builder()
                            .user(agent)
                            .agentCode(agentCode)
                            .businessName(agent.getPhone())
                            .depositCommissionRate(new BigDecimal("1.0"))
                            .withdrawalCommissionRate(new BigDecimal("1.5"))
                            .verified(false)
                            .build();
                    agentProfileRepository.save(profile);
                    log.info("Agent profile created for user {} with code {}", agent.getPhone(), agentCode);
                    return profile;
                });
    }

    private String generateAgentCode() {
        String code;
        do {
            code = "AG" + String.format("%06d", (int) (Math.random() * 1000000));
        } while (agentProfileRepository.existsByAgentCode(code));
        return code;
    }
}
