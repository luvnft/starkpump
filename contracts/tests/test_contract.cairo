use core::starknet::SyscallResultTrait;
use snforge_std::{declare, ContractClassTrait};
use contracts::token::{ITokenDispatcher, ITokenDispatcherTrait};
use contracts::factory::{IFactoryDispatcher, IFactoryDispatcherTrait};

#[test]
fn test_token_message() {
    let name = 'TestToken';
    let symbol = 'TTK';
    let initial_supply = u256 { low: 1000, high: 0 };

    let contract = declare("Token").unwrap();
    let mut calldata = ArrayTrait::new();
    calldata.append(name);
    calldata.append(symbol);
    calldata.append(initial_supply.low.into());
    calldata.append(initial_supply.high.into());
    let (contract_address, _) = contract.deploy(@calldata).unwrap_syscall();

    let dispatcher = ITokenDispatcher { contract_address };

    let message = dispatcher.get_message();
    assert(message == 'Token contract', 'Incorrect token message');
}

#[test]
fn test_factory_message() {
    let token_contract = declare("Token").unwrap();
    let token_class_hash = token_contract.class_hash;

    let factory_contract = declare("Factory").unwrap();
    let mut factory_calldata = ArrayTrait::new();
    factory_calldata.append(token_class_hash.into());
    let (contract_address, _) = factory_contract.deploy(@factory_calldata).unwrap_syscall();

    let dispatcher = IFactoryDispatcher { contract_address };

    let message = dispatcher.get_message();
    assert(message == 'Factory contract', 'Incorrect factory message');
}

#[test]
fn test_token_deploy() {
    let name = 'MyToken';
    let symbol = 'MTK';
    let initial_supply = u256 { low: 1000000, high: 0 };

    let contract = declare("Token").unwrap();
    let mut calldata = ArrayTrait::new();
    calldata.append(name);
    calldata.append(symbol);
    calldata.append(initial_supply.low.into());
    calldata.append(initial_supply.high.into());
    let (contract_address, _) = contract.deploy(@calldata).unwrap_syscall();

    let dispatcher = ITokenDispatcher { contract_address };

    assert(dispatcher.name() == name, 'Incorrect token name');
    assert(dispatcher.symbol() == symbol, 'Incorrect token symbol');
    assert(dispatcher.total_supply() == initial_supply, 'Incorrect total supply');
}

#[test]
fn test_factory_deploy_token() {
    // First, declare the Token contract
    let token_contract = declare("Token").unwrap();
    let token_class_hash = token_contract.class_hash;

    // Now, declare and deploy the Factory contract with the Token class hash
    let factory_contract = declare("Factory").unwrap();
    let mut factory_calldata = ArrayTrait::new();
    factory_calldata.append(token_class_hash.into());
    let (factory_address, _) = factory_contract.deploy(@factory_calldata).unwrap_syscall();

    let factory_dispatcher = IFactoryDispatcher { contract_address: factory_address };

    // Use the factory to deploy a new token
    let name = 'MyToken';
    let symbol = 'MTK';
    let initial_supply = u256 { low: 1000000, high: 0 };
    let token_address = factory_dispatcher.deploy_token(name, symbol, initial_supply);

    // Verify the deployed token
    let token_dispatcher = ITokenDispatcher { contract_address: token_address };
    assert(token_dispatcher.name() == name, 'Incorrect token name');
    assert(token_dispatcher.symbol() == symbol, 'Incorrect token symbol');
    assert(token_dispatcher.total_supply() == initial_supply, 'Incorrect total supply');
}