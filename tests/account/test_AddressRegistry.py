import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils import Signer, contract_path

signer = Signer(123456789987654321)
L1_ADDRESS = 0x1F9840A85D5AF5BF1D1762F925BDADDC4201F984
ANOTHER_ADDRESS = 0xD9E1CE17F2641F24AE83637AB66A2CCA9C378B9F


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
async def account_factory():
    starknet = await Starknet.empty()
    registry = await starknet.deploy(
        contract_path("contracts/account/AddressRegistry.cairo")
    )
    account = await starknet.deploy(
        contract_path("contracts/account/Account.cairo"),
        constructor_calldata=[signer.public_key],
    )

    return starknet, account, registry


@pytest.mark.asyncio
async def test_set_address(account_factory):
    _, account, registry = account_factory

    await signer.send_transaction(
        account, registry.contract_address, "set_L1_address", [L1_ADDRESS]
    )
    execution_info = await registry.get_L1_address(account.contract_address).call()
    assert execution_info.result == (L1_ADDRESS,)


@pytest.mark.asyncio
async def test_update_address(account_factory):
    _, account, registry = account_factory

    await signer.send_transaction(
        account, registry.contract_address, "set_L1_address", [L1_ADDRESS]
    )

    execution_info = await registry.get_L1_address(account.contract_address).call()
    assert execution_info.result == (L1_ADDRESS,)

    # set new address
    await signer.send_transaction(
        account, registry.contract_address, "set_L1_address", [ANOTHER_ADDRESS]
    )

    execution_info = await registry.get_L1_address(account.contract_address).call()
    assert execution_info.result == (ANOTHER_ADDRESS,)
