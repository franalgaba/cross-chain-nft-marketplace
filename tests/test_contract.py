import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils import Signer, contract_path

signer = Signer(123456789987654321)
L1_ADDRESS = 0x1F9840A85D5AF5BF1D1762F925BDADDC4201F984
L2_ADDRESS = 0xD9E1CE17F2641F24AE83637AB66A2CCA9C378B9F
L1_RECIPIENT_ADDRESS = 0x0000000000000000000000000000000000000000
TOKEN_CONTRACT = 0x0000000000000000000000000000000000000001


def check_event(event_name, tx, values):
    print(tx)
    event = tx.main_call_events[0]
    assert type(event).__name__ == event_name
    assert event == values


@pytest.fixture(scope="function")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="function")
async def account_factory():
    starknet = await Starknet.empty()
    account = await starknet.deploy(
        contract_path("contracts/account/Account.cairo"),
        constructor_calldata=[signer.public_key],
    )
    contract = await starknet.deploy("contracts/contract.cairo")

    return starknet, account, contract


@pytest.mark.asyncio
async def test_register_user(account_factory):
    _, account, contract = account_factory

    await contract.register_user(L1_ADDRESS).invoke(L2_ADDRESS)

    response = await contract.get_l1_registered_address().call(L2_ADDRESS)
    assert response.result.address == L1_ADDRESS


@pytest.mark.asyncio
async def test_list_erc721(account_factory):
    _, account, contract = account_factory

    await contract.register_user(L1_ADDRESS).invoke(L2_ADDRESS)

    token_contract = TOKEN_CONTRACT
    token_id = 1
    ask_price = 1
    ask_currency = 0
    seller_funds_recipient = L1_RECIPIENT_ADDRESS
    finders_fee_bps = 200

    tx = await contract.list_erc721(
        token_contract,
        token_id,
        ask_price,
        ask_currency,
        seller_funds_recipient,
        finders_fee_bps,
    ).invoke(L2_ADDRESS)

    assert len(tx.l2_to_l1_messages) == 1

    l2_to_l1_message = tx.l2_to_l1_messages[0]

    assert l2_to_l1_message.payload == [
        token_contract,
        token_id,
        ask_price,
        ask_currency,
        seller_funds_recipient,
        finders_fee_bps,
    ]


@pytest.mark.asyncio
async def test_buy_erc721(account_factory):
    _, account, contract = account_factory

    await contract.register_user(L1_ADDRESS).invoke(L2_ADDRESS)

    token_contract = TOKEN_CONTRACT
    token_id = 1
    fill_currency = 1
    fill_amount = 0
    finder = L1_RECIPIENT_ADDRESS

    tx = await contract.buy_erc721(
        token_contract,
        token_id,
        fill_currency,
        fill_amount,
        finder,
    ).invoke(L2_ADDRESS)

    assert len(tx.l2_to_l1_messages) == 1

    l2_to_l1_message = tx.l2_to_l1_messages[0]

    assert l2_to_l1_message.payload == [
        token_contract,
        token_id,
        fill_currency,
        fill_amount,
        finder,
    ]
