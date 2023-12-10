module monky_food_recipes::recipes {
    use std::option::{Self, Option};
    use std::string::{Self, String};

    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};

    use sui::object_table::{Self, ObjectTable};
    use sui::event;

    const NOT_THE_OWNER: u64 = 0;

    struct Recipe has key, store {
        id: UID,
        name: String,
        owner: address,
        title: String,
        img_url: Url,
        description: Option<String>,
        contact: String
    }

    struct CreatorHub has key {
        id: UID,
        owner: address,
        counter: u64,
        recipes: ObjectTable<u64, Recipe>,
    }

    struct RecipeCreated has copy, drop {
        id: ID,
        name: String,
        owner: address,
        title: String,
        contact: String
    }

    struct DescriptionUpdated has copy, drop {
        name: String,
        owner: address,
        new_description: String
    }


    fun init(ctx: &mut TxContext) {
        transfer::share_object({
            let id = object::new(ctx);
            CreatorHub {
                id: id,
                owner: tx_context::sender(ctx),
                counter: 0,
                recipes: object_table::new(ctx),
            }
        });
    }

    public entry fun create_recipe (
        name: vector<u8>,
        title: vector<u8>,
        img_url: vector<u8>,
        contact: vector<u8>,
        creatorHub: &mut CreatorHub,
        ctx: &mut TxContext
    ) {
        creatorHub.counter = creatorHub.counter + 1;

        let id = object::new(ctx);

        event::emit(
            RecipeCreated {
                id: object::uid_to_inner(&id),
                name: string::utf8(name),
                owner: tx_context::sender(ctx),
                title: string::utf8(title),
                contact: string::utf8(contact),
            }
        );

        let recipe = Recipe {
            id: id,
            name: string::utf8(name),
            owner: tx_context::sender(ctx),
            title: string::utf8(title),
            img_url: url::new_unsafe_from_bytes(img_url),
            description: option::none(),
            contact: string::utf8(contact)
        };

        object_table::add(&mut creatorHub.recipes, creatorHub.counter, recipe);
    }

    public entry fun update_recipe_description(creatorHub: &mut CreatorHub, new_description: vector<u8>, id: u64, ctx: &mut TxContext) {
        let user_recipe = object_table::borrow_mut(&mut creatorHub.recipes, id);
        assert!(tx_context::sender(ctx) == user_recipe.owner, NOT_THE_OWNER);

        let old_value = option::swap_or_fill(&mut user_recipe.description, string::utf8(new_description));

        event::emit(
            DescriptionUpdated {
                name: user_recipe.name,
                owner: user_recipe.owner,
                new_description: string::utf8(new_description)
            }
        );

        _ = old_value;
    }

    public fun get_recipe(creatorHub: &CreatorHub, id: u64): &Recipe {
       object_table::borrow(&creatorHub.recipes, id)
    }

    public fun get_recipe_description(creatorHub: &CreatorHub, id: u64): String {
        let recipe = get_recipe(creatorHub, id);
        
        return option::destroy_some(recipe.description)
    }

    public fun creator_hub_owner(self: &CreatorHub): address {
        self.owner
    }

    public fun recipe_count(self: &CreatorHub): u64 {
        self.counter
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }

    
}