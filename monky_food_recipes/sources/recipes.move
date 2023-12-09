module monky_food_recipes::recipes {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    struct CreatorCapability has key {
        id: UID
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(CreatorCapability {
            id: object::new(ctx),
        }, tx_context::sender(ctx))
    }
}