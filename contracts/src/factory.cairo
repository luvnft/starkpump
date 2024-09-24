use starknet::{ContractAddress, ClassHash};
use contracts::token::{ITokenDispatcher, ITokenDispatcherTrait};

#[starknet::interface]
trait IFactory<TContractState> {
    fn get_message(self: @TContractState) -> felt252;
    fn deploy_token(
        ref self: TContractState,
        name: felt252,
        symbol: felt252,
        initial_supply: u256
    ) -> ContractAddress;
}

#[starknet::contract]
mod Factory {
    use super::IFactory;
    use starknet::{ContractAddress, ClassHash, syscalls::deploy_syscall};
    use core::array::ArrayTrait;
    use core::result::ResultTrait;

    #[storage]
    struct Storage {
        token_class_hash: ClassHash,
    }

    #[constructor]
    fn constructor(ref self: ContractState, token_class_hash: ClassHash) {
        self.token_class_hash.write(token_class_hash);
    }

    #[abi(embed_v0)]
    impl FactoryImpl of IFactory<ContractState> {
        fn get_message(self: @ContractState) -> felt252 {
            'Factory contract'
        }

        fn deploy_token(
            ref self: ContractState,
            name: felt252,
            symbol: felt252,
            initial_supply: u256
        ) -> ContractAddress {
            let mut calldata = ArrayTrait::new();
            calldata.append(name);
            calldata.append(symbol);
            calldata.append(initial_supply.low.into());
            calldata.append(initial_supply.high.into());

            let (address, _) = deploy_syscall(
                self.token_class_hash.read(),
                0,
                calldata.span(),
                false
            ).unwrap();

            address
        }
    }
}