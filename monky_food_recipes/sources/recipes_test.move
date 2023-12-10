#[test_only]
module monky_food_recipes::recipes_test {
    use std::string;
    use sui::test_scenario;
    
    use monky_food_recipes::recipes::{Self, CreatorHub};
    //use sui::tx_context;

    #[test]
    fun test_create() {
        let owner = @0xA;
        // let user1 = @0xB;
        // let user2 = @0xC;

        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;
        
        test_scenario::next_tx(scenario, owner);
        {
            recipes::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, owner);
        {
            let creatorHub = test_scenario::take_shared<CreatorHub>(scenario);
            assert!(recipes::creator_hub_owner(&creatorHub) == owner, 0);
            test_scenario::return_shared(creatorHub);
        };

        test_scenario::next_tx(scenario, owner);
        {
            let creatorHub = test_scenario::take_shared<CreatorHub>(scenario);
            let prevNumRecipes = recipes::recipe_count(&creatorHub);
            
            recipes::create_recipe(
                b"Orange Juice", 
                b"Fresh Orange Juice",
                b"",
                b"monky@example.com",
                &mut creatorHub,
                test_scenario::ctx(scenario)
            );

            let numRecipes = recipes::recipe_count(&creatorHub);
            assert!(numRecipes > prevNumRecipes, 1);

            test_scenario::return_shared(creatorHub);
        };

        test_scenario::next_tx(scenario, owner);
        {
            let creatorHub = test_scenario::take_shared<CreatorHub>(scenario);
            let numRecipes = recipes::recipe_count(&creatorHub);
            let description = b"1 Serving: Squeeze 3x fresh oranges";
            recipes::update_recipe_description(
                &mut creatorHub, 
                description,
                numRecipes,
                test_scenario::ctx(scenario)
            );

            let recipeDescription = recipes::get_recipe_description(&creatorHub, numRecipes);
            assert!(recipeDescription == string::utf8(description), 1);

            test_scenario::return_shared(creatorHub);
        };

        test_scenario::end(scenario_val);
    }
}