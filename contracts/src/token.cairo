#[starknet::interface]
trait IToken<TContractState> {
    fn get_message(self: @TContractState) -> felt252;
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn total_supply(self: @TContractState) -> u256;
}

#[starknet::contract]
mod Token {
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        total_supply: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        initial_supply: u256,
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.total_supply.write(initial_supply);
    }

    #[abi(embed_v0)]
    impl TokenImpl of super::IToken<ContractState> {
        fn get_message(self: @ContractState) -> felt252 {
            'Token contract'
        }

        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }
    }
}