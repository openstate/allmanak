<script>
    import BoxLinks from './BoxLinks.svelte';
    import { categories } from '../stores.js';
</script>

<div class='categorybar'>
    <div class='container'>
        <h3>&gt; Zoek op categorie in <strong>Overheidsorganisaties</strong></h3>
        <BoxLinks items={[$categories].map(x=>({link:`cat/${x.catnr}`, name:x.naam}))}/>
    </div>
</div>
<style>
    :global(body.fontloaded-montserratsemibold) .categorybar, :global(body.fontloaded-montserratsemibold) h3 strong {
        font-family: 'montserratsemibold';
    }
    :global(body.fontloaded-montserratregular) h3 {
        font-family: 'montserratregular';
    }
    .categorybar {
        background-color: #f2f2f2;
        color: #3d4a4c;
    }
    h3 {
        font-size: 2rem;
        font-weight: normal;
        margin-bottom: 2rem;
    }
    h3 strong {
        font-weight: 600;
    }
</style>