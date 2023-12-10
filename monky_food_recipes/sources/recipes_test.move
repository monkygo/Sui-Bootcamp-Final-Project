#[test_only]
module monky_food_recipes::recipes_test {
    use sui::test_scenario;
    use monky_food_recipes::recipes::{Self, Recipe, CreatorHub, RecipeCreated, DescriptionUpdated};
    use sui::clock::{Self, Clock};
    use sui::tx_context;

    #[test]
    fun test_create() {
        let owner = @0xA;
        let user1 = @0xB;
        let user2 = @0xC;

        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, owner);
        {
            recipes::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, owner);
        {
            let creatorHub = test_scenario::take_from_sender<CreatorHub>(scenario);
            let ctx = test_scenario::ctx(scenario);
            let clock = clock::create_for_testing(ctx);
            recipes::create_recipe(
                &clock,
                b"Orange Juice",
                b"Fresh Squeeze Orange Juice",
                b"",
                b"Monky@Example.com",
                &mut creatorHub,
                ctx
            );

            clock::destroy_for_testing(clock);
            test_scenario::return_to_sender(scenario, creatorHub);
        };

        test_scenario::end(scenario_val);
    }
}