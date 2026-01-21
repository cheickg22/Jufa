package ml.jufa.backend.b2b.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Data
public class CreateOrderRequest {

    @NotNull(message = "Wholesaler ID is required")
    private UUID wholesalerId;

    @NotEmpty(message = "Order must have at least one item")
    @Valid
    private List<OrderItemRequest> items;

    private String notes;

    private String deliveryAddress;

    private LocalDate expectedDeliveryDate;

    private Boolean useCredit = false;
}
