# Declare this file as a StarkNet contract.
%lang starknet

from contracts.account.AddressRegistry import get_L1_address, set_L1_address
from contracts.utils.constants import L1_CONTRACT_ADDRESS

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address
from starkware.starknet.common.messages import send_message_to_l1

############
# External #
############

# Register new user with L1 credentials
@external
func register_user{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        l1_address : felt) -> ():
    let (caller_address) = get_caller_address()
    # validate is new user
    let (caller_l1_address) = get_L1_address(caller_address)

    assert caller_l1_address = 0

    set_L1_address(l1_address)

    return ()
end

# List
@external
func list_erc721{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token_contract : felt, token_id : felt, ask_price : felt, ask_currency : felt,
        seller_funds_recipient : felt, finders_fee_bps : felt) -> ():
    let (caller_address) = get_caller_address()
    let (caller_l1_address) = get_L1_address(caller_address)

    # validate user is already registered
    assert_not_zero(caller_l1_address)

    # Create a dynamically sized array for the message.
    let (message : felt*) = alloc()

    # _tokenContract: The address of the ERC-721 token to be sold
    assert message[0] = token_contract

    # _tokenId: The ID of the ERC-721 token to be sold
    assert message[1] = token_id

    # _askPrice: The price to fill the ask
    assert message[2] = ask_price

    # _askCurrency: The address of the ERC-20 token required to fill, or address(0) for ETH
    assert message[3] = ask_currency

    # _sellerFundsRecipient: The address to send funds once the ask is filled
    assert message[4] = seller_funds_recipient

    # Finders fee calculation: https://docs.zora.co/docs/guides/sell-nft-fixed-price#setting-the-finders-fee
    # _findersFeeBps: The bps of the ask price (post-royalties) to be sent to the referrer of the sale
    assert message[5] = finders_fee_bps

    # Send the message.
    send_message_to_l1(to_address=L1_CONTRACT_ADDRESS, payload_size=6, payload=message)

    return ()
end

# Buy
@external
func buy_erc721{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(token_contract : felt, token_id : felt, fill_currency : felt, fill_amount : felt,
        finder : felt) -> ():
    let (caller_address) = get_caller_address()
    let (caller_l1_address) = get_L1_address(caller_address)

    # validate user is already registered
    assert_not_zero(caller_l1_address)

    # Create a dynamically sized array for the message.
    let (message : felt*) = alloc()

    # _tokenContract: The address of the ERC-721 token to be sold
    assert message[0] = token_contract

    # _tokenId: The ID of the ERC-721 token to be sold
    assert message[1] = token_id

    # _fillCurrency: The address of the ERC-20 token using to fill, or address(0) for ETH
    assert message[2] = fill_currency

    # _fillAmount: The amount to fill the ask
    assert message[3] = fill_amount

    # _finder: The address of the ask referrer
    assert message[4] = finder

    # Send the message.
    send_message_to_l1(to_address=L1_CONTRACT_ADDRESS, payload_size=5, payload=message)

    return ()
end

########
# View #
########

# Returns the registered L1 address.
@view
func get_l1_registered_address{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (address : felt):
    let (caller_address) = get_caller_address()
    let (caller_l1_address) = get_L1_address(caller_address)
    return (caller_l1_address)
end