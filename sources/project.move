module MyModule::TokenTransferDashboard {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

    /// Struct representing a user's transfer dashboard
    struct Dashboard has store, key {
        total_sent: u64,        // Total tokens sent by the user
        total_received: u64,    // Total tokens received by the user
        transfer_count: u64,    // Number of transfers made
        recipients: vector<address>, // List of recipients
    }

    /// Function to initialize a dashboard for a user
    public fun initialize_dashboard(user: &signer) {
        let dashboard = Dashboard {
            total_sent: 0,
            total_received: 0,
            transfer_count: 0,
            recipients: vector::empty<address>(),
        };
        move_to(user, dashboard);
    }

    /// Function to transfer tokens and update dashboard statistics
    public fun transfer_tokens(
        sender: &signer, 
        recipient_addr: address, 
        amount: u64
    ) acquires Dashboard {
        // Perform the actual token transfer
        let tokens = coin::withdraw<AptosCoin>(sender, amount);
        coin::deposit<AptosCoin>(recipient_addr, tokens);

        let sender_addr = signer::address_of(sender);
        
        // Update sender's dashboard
        let sender_dashboard = borrow_global_mut<Dashboard>(sender_addr);
        sender_dashboard.total_sent = sender_dashboard.total_sent + amount;
        sender_dashboard.transfer_count = sender_dashboard.transfer_count + 1;
        
        // Add recipient to the list if not already present
        if (!vector::contains(&sender_dashboard.recipients, &recipient_addr)) {
            vector::push_back(&mut sender_dashboard.recipients, recipient_addr);
        };

        // Update recipient's dashboard if they have one
        if (exists<Dashboard>(recipient_addr)) {
            let recipient_dashboard = borrow_global_mut<Dashboard>(recipient_addr);
            recipient_dashboard.total_received = recipient_dashboard.total_received + amount;
        };
    }
}