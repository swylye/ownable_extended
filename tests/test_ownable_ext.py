from brownie import TestToken, accounts, config, network, exceptions, convert
from web3 import Web3
from scripts.deploy import deploy_contract
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account
import pytest


def test_only_owner_can_mint():
    test_token, account = deploy_contract()
    mint_amount = 1000 * 10**18
    test_token.mint(mint_amount, {"from": account})
    assert test_token.totalSupply() == mint_amount
    assert test_token.balanceOf(account) == mint_amount
    # non owner cannot mint
    account2 = get_account(index=1)
    with pytest.raises(exceptions.VirtualMachineError):
        test_token.mint(mint_amount, {"from": account2})


def test_direct_transfer():
    test_token, account = deploy_contract()
    account2 = get_account(index=1)
    # non owner cannot transfer ownership
    with pytest.raises(exceptions.VirtualMachineError):
        test_token.transferOwnership(account, {"from": account2})
    test_token.transferOwnership(account2, {"from": account})
    assert test_token.owner() == account2.address


def test_two_step_transfer():
    test_token, account = deploy_contract()
    account2 = get_account(index=1)
    # non owner cannot nominate new owner
    with pytest.raises(exceptions.VirtualMachineError):
        test_token.nominateNewOwner(account2, {"from": account2})
    test_token.nominateNewOwner(account2, {"from": account})
    # non nominee cannot accept nomination
    with pytest.raises(exceptions.VirtualMachineError):
        test_token.acceptNomination({"from": account})
    test_token.acceptNomination({"from": account2})
    assert test_token.owner() == account2.address


def test_two_step_transfer_with_password():
    test_token, account = deploy_contract()
    account2 = get_account(index=1)
    password = "Hello world!"
    hashed_password = test_token.hashString(password)
    not_password = "Hello Pluto!"
    # non owner cannot nominate new owner
    with pytest.raises(exceptions.VirtualMachineError):
        test_token.nominateNewOwnerPW(account2, hashed_password, {"from": account2})
    test_token.nominateNewOwnerPW(account2, hashed_password, {"from": account})
    # non nominee cannot accept nomination
    with pytest.raises(exceptions.VirtualMachineError):
        test_token.acceptNominationPW(password, {"from": account})
    # nominee cannot accept nomination with wrong password
    with pytest.raises(exceptions.VirtualMachineError):
        test_token.acceptNominationPW(not_password, {"from": account2})
    test_token.acceptNominationPW(password, {"from": account2})
    assert test_token.owner() == account2.address
