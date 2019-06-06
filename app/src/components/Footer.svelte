<script>
  import {urlname} from '../utils.js';
  import { categories, showReportModal } from '../stores.js';
</script>

<footer>
    <div class='lead'>
        <div class='container'>
            <h1 class='brand-header'><a href='.'><img class='logo' src='allmanak-logo-white.svg' alt='Allmanak'></a></h1><p class='lead-text'>Zoeken naar contactgegevens overheden en politici</p>
        </div>
    </div>
   <div class='navbar'>
        <div class='container'>
            <nav>
                <ul>
                    <li><a href='waarom'>Waarom deze Allmanak</a></li>
                    <li><a href='api'>API</a></li>
                    <li><a href='https://openstate.eu/nl/contact' target='_blank' rel='noopener'>Contact</a></li>
                    <li><a class='report-error' href='#' on:click|stopPropagation|preventDefault='{() => $showReportModal=true}'>Meld een fout</a></li>
                    {#each $categories as category}
                      <li><a href='cat/{category.catnr}/{urlname(category.naam)}'>{category.naam}</a></li>
                    {/each}
                </ul>
            </nav>
        </div>
    </div>
    <div class="creditbar">
        <div class='container'>
            <div class='credits'>
                <div>
                    <h6>Een initiatief van</h6>
                    <a href='https://openstate.eu/' target='_blank' rel='noopener'><img class='logo' src='logo-open-state-foundation.svg' alt='Open State Foundation'></a>
                </div>
                <div>
                    <h6>mede mogelijk gemaakt met steun van</h6>
                    <a href='https://www.sidnfonds.nl/' target='_blank' rel='noopener'><img class='logo' src='logo-sidnfonds.svg' alt='SIDN Fonds'></a>
                </div>
            </div>
        </div>
    </div>
</footer>
<style>
    .navbar {
        background-color: #076776;
        color: #FFF;
        font-weight: 600;
    }
    .creditbar {
        background-color: #f2f2f2;
        color: #3d4a4c;
        font-weight: 600;
    }
    :global(body.fontloaded-montserratsemibold) .navbar, :global(body.fontloaded-montserratsemibold) .creditbar {
        font-family: 'montserratsemibold';
    }
    .navbar > .container {
        padding-bottom: 2rem;
        padding-top: 0.5rem;
    }
    .lead {
        background-color: #3d4a4c;
        color: #FFFFFF;
    }
    :global(body.fontloaded-montserratregular) .lead {
        font-family: 'montserratregular';
    }
    .lead > .container {
        padding-bottom: 1rem;
        padding-top: 1rem;
    }
    .brand-header {
        display: inline-block;
        text-decoration: none;
    }
    .brand-header .logo {
        height: 50px;
    }
    .lead-text {
        display: inline-block;
        font-size: 1.5rem;
        margin-left: 2rem;
        vertical-align: bottom;
    }
    /*.report-error {
        color: #c2178a;
    }*/
    nav {
        /*border-bottom: 1px solid rgba(170,30,30,0.1);*/
        font-weight: 300;
    }
    .navbar ul {
        margin: 0;
        padding: 0;
        display: flex;
        flex-direction: column;
        flex-wrap: wrap;
        justify-content: space-between;
    }
    li {
        height: 3rem;
        line-height: 1rem;
        box-sizing: border-box;
        display: block;
        /*background-color: #fff;
        margin-bottom: 1rem;
        min-height: 14rem;*/
        text-decoration: none;
        display: block;
        cursor: pointer;
    }
    @media (min-width: 768px) {
        .navbar ul {
            max-height: 19rem;
        }
        li {
            padding: 0.5rem 1rem;
            width: 24%;
            height: 4rem;
        }
    }
    nav a {
        text-decoration: none;
        padding: 1em 1em;
        display: block;
        cursor: pointer;
    }
    .credits {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(14rem, 1fr));
        grid-gap: 1rem;
    }
    .credits img {
        height: 75px;
        max-width: 250px;
    }
</style>