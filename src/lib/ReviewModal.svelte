<script lang="ts">
    import { createEventDispatcher } from 'svelte';

    // Define the type for the data submitted by the modal
    interface ReviewData {
        volunteerName: string;
        rating: number;
        review: string;
    }

    /**
     * @type {number} The currently selected star rating (1 to 5).
     * @default 0
     */
    export let rating: number = 0;
    
    /**
     * @type {string} The name of the volunteer being reviewed.
     * @default 'Volunteer'
     */
    export let volunteerName: string = 'Volunteer';

    /**
     * @type {boolean} Controls the visibility of the modal.
     * @default false
     */
    export let isVisible: boolean = false;

    let reviewText: string = '';
    const MAX_CHARACTERS = 150;
    
    // Dispatcher for typed events
    const dispatch = createEventDispatcher<{
        submitReview: ReviewData;
        close: void;
    }>();

    /**
     * Called when the user clicks the "Submit Review" button.
     * @returns {void}
     */
    function handleSubmit(): void {
        // Simple validation
        if (rating === 0 || reviewText.trim() === '') {
            alert('Please select a star rating and provide a short review.');
            return;
        }

        // Dispatch the review data
        dispatch('submitReview', {
            volunteerName,
            rating,
            review: reviewText.trim()
        });
        
        // Reset and close the modal
        resetAndClose();
    }

    /**
     * Called when the user clicks the "Cancel" button or the backdrop.
     * @returns {void}
     */
    function resetAndClose(): void {
        rating = 0;
        reviewText = '';
        isVisible = false;
        dispatch('close');
    }

    /**
     * Handles setting the rating when a star is clicked.
     * @param {number} newRating - The rating value (1-5).
     * @returns {void}
     */
    function setRating(newRating: number): void {
        rating = newRating;
    }

    // A simple array for iterating over the stars (1 to 5)
    const starIndices = [1, 2, 3, 4, 5];
</script>

{#if isVisible}
<div 
    class="fixed inset-0 bg-gray-900 bg-opacity-75 flex items-center justify-center z-50 p-4"
    on:click={resetAndClose}
    on:keydown={(e) => { if (e.key === 'Escape') resetAndClose(); }}
    role="dialog"
    aria-modal="true"
>
    <div 
        class="bg-white rounded-xl shadow-2xl p-6 w-full max-w-md"
        on:click|stopPropagation
        role="document"
    >
        <h2 class="text-2xl font-semibold text-gray-800 mb-2 border-b pb-2">
            Review {volunteerName}
        </h2>
        <p class="text-gray-500 mb-6">Your feedback is valuable and helps our team!</p>

        <form on:submit|preventDefault={handleSubmit}>
            <div class="mb-5">
                <label for="rating" class="block text-sm font-medium text-gray-700 mb-1">Rating</label>
                <div class="star-rating text-4xl leading-none flex flex-row-reverse justify-end">
                    {#each starIndices as index (index)}
                        <button 
                            type="button"
                            class="text-gray-300 transition-colors duration-150 ease-in-out cursor-pointer focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2 hover:text-yellow-400"
                            class:text-yellow-400={index <= rating}
                            aria-label="Rate {index} out of 5"
                            on:click={() => setRating(index)}
                        >
                            <span class="p-1">★</span>
                        </button>
                    {/each}
                </div>
                {#if rating > 0}
                    <p class="text-sm text-gray-500 mt-2">You rated: <span class="font-medium text-yellow-600">{rating}</span> out of 5</p>
                {/if}
            </div>
            
            <div class="mb-6">
                <label for="review" class="block text-sm font-medium text-gray-700 mb-1">Short Review (Max {MAX_CHARACTERS} chars)</label>
                <textarea 
                    id="review"
                    bind:value={reviewText}
                    maxlength={MAX_CHARACTERS}
                    class="w-full p-3 border border-gray-300 rounded-lg shadow-sm focus:ring-blue-500 focus:border-blue-500 resize-y min-h-[80px]"
                    placeholder="E.g., 'They were punctual and very helpful with setup!'"
                    required
                ></textarea>
                <p class="text-xs text-gray-500 text-right mt-1">
                    {reviewText.length} / {MAX_CHARACTERS} characters
                </p>
            </div>

            <div class="flex justify-end space-x-3">
                <button 
                    type="button" 
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-lg hover:bg-gray-200 transition-colors"
                    on:click={resetAndClose}
                >
                    Cancel
                </button>
                <button 
                    type="submit" 
                    class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors disabled:bg-blue-300 disabled:cursor-not-allowed"
                    disabled={rating === 0 || reviewText.trim() === ''}
                >
                    Submit Review
                </button>
            </div>
        </form>
    </div>
</div>
{/if}
