<script>
  export let items;
</script>

<div class='boxes'>
{#each items as item}
    <a class='item' href='{item.link}'>{item.name}</a>
{/each}
    <!-- <div class='filler'></div> -->
</div>
<style>
    .boxes {
        display: grid;
        /*grid-template: none repeat(auto-fill, 100px) / repeat(auto-fill, 100px);*/
        grid-template-columns: repeat(auto-fill, minmax(14rem, 1fr));
        grid-gap: 1rem;
    }
    /*.boxes {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        align-items: flex-start;
        justify-content: space-between;
    }*/
    .item {
        box-sizing: border-box;
        padding: 2rem;
        min-height: 5rem;
        display: block;
        background-color: #fff;
        text-decoration: none;
        display: block;
        cursor: pointer;
        /*word-wrap: break-word;*/
        -webkit-hyphens: auto;
        -moz-hyphens: auto;
        -ms-hyphens: auto;
        hyphens: auto;
        /*height: 14rem;
        width: 14rem;
        margin-bottom: 1rem;*/
    }
    @media (min-width: 768px) {
        .item {
            padding: 3rem;
            min-height: 14rem;
        }
    }
    .item:hover {
        background-color: #076776;
        color: #FFF;
    }
    /*.filler {
        flex-grow: 1;
    }*/
</style>