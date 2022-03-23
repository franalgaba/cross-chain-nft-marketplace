import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils import Signer

signer = Signer(123456789987654321)
L1_ADDRESS = 0x1F9840A85D5AF5BF1D1762F925BDADDC4201F984
L2_ADDRESS = 0xD9E1CE17F2641F24AE83637AB66A2CCA9C378B9F


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
async def account_factory():
    starknet = await Starknet.empty()
    contract = await starknet.deploy("contracts/contract.cairo")

    return starknet, contract


# @pytest.mark.asyncio
# async def test_is_new_user(account_factory):
#     _, contract = account_factory

#     assert await contract.is_new_user(address=L2_ADDRESS).invoke() == 1
