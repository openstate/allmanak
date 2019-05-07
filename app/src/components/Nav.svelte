<script>
  import { createEventDispatcher } from 'svelte';
  import {slide} from 'svelte/transition';
  import {urlname} from '../utils.js';

  export let categories;
  export let segment;

  const dispatch = createEventDispatcher();

  let headerOffsetHeight;
  let navbarOffsetHeight;
  let header;
  let menuOpen = false;
  let scrollY;
  let submenu;

  $: show = header && scrollY > headerOffsetHeight + header.offsetTop - navbarOffsetHeight;
</script>

<svelte:window bind:scrollY on:click|stopPropagation={() => menuOpen = false, submenu = false} />

<header bind:offsetHeight={headerOffsetHeight} bind:this={header}>
    <div class='navbar' bind:offsetHeight={navbarOffsetHeight}>
        <div class='container'>
            <div class="header">
                <span class='menu' on:click|stopPropagation="{() => menuOpen = !menuOpen, submenu = false}">{ menuOpen ? 'Close \u00D7' : 'Menu \u2630' }</span>
                <h1 class='brand-header' class:show><a href='.'><img class='logo' src='allmanak-logo.svg' alt='Allmanak'></a></h1>
            </div>
            <nav>
                <ul class:opened='{menuOpen}' transition:slide>
                    <li><a class:selected='{segment === "waarom"}' href='waarom'>Waarom deze Allmamak</a></li>
                    <li><a href='#' class:active='{submenu}' on:click|stopPropagation|preventDefault='{() => submenu = !submenu}'>Gegevens overheden</a>
                        {#if submenu}
                        <div class='subnavbar' on:click|stopPropagation='{() => menuOpen = false, submenu = false}'>
                          <div class='container'>
                            <ul class='submenu' transition:slide>
                            {#each categories as category}
                              <li><a href='cat/{category.catnr}/{urlname(category.naam)}'>{category.naam}</a></li>
                            {/each}
                            </ul>
                          </div>
                        </div>
                        {/if}
                    </li>
                    <li><a class:selected='{segment === "api"}' href='api'>API</a></li>
                    <li><a  href='https://openstate.eu/nl/contact' target='_blank' rel='noopener'>Contact</a></li>
                    <li><a href='#' on:click|preventDefault='{() => dispatch("report")}' class="report-error" >Meld een fout</a></li>
                </ul>
            </nav>
        </div>
    </div>
    <div class='lead'>
        <div class='container'>
            <h1 class='brand-header'><a href='.'><img class='logo' src='allmanak-logo.svg' alt='Allmanak'></a></h1><p class='lead-text'>Zoeken naar contactgegevens overheden en politici</p>
        </div>
    </div>
</header>

<style>
    .navbar {
        background-color: #FFF;
        font-weight: 600;
        min-height: 3rem;
        /*overflow: hidden;*/
        position: fixed;
        z-index: 1;
        border-bottom: 1px solid #ccc;
        left: 0;
        top: 0;
        width: 100%;
        overflow: auto;
        min-width: 320px;
        max-height: 100vh;
    }
    .header {
        position: fixed;
        background: #FFF;
        border-bottom: 1px solid #ccc;
        min-height: 3rem;
        left: 0;
        top: 0;
        width: 100%;
        min-width: 320px;
        z-index: 2;
    }
    .navbar > .container > nav {
        margin-top: 3rem;
    }
    .lead {
        margin-top: 3rem;
    }
    :global(body.fontloaded-montserratsemibold) .navbar, :global(body.fontloaded-montserratsemibold) .subnavbar {
        font-family: 'montserratsemibold';
    }
    .navbar .menu {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 1rem;
        float: right;
        height: 3rem;
        width: 5rem;
        background: #FFF;
        text-align: center;
        line-height: 3rem;
        user-select: none;
    }
    .navbar .menu:hover {
        background: #EFEFEF;
    }
    .navbar > .container > .header > .brand-header {
        margin: 0.5rem 0.5rem 0 0.5rem;
        display: inline-block;
        text-decoration: none;
    }
    .lead > .container > .brand-header {
        margin: 0.5rem;
    }
    .opened .container {
        padding: 0 0 0 1rem;
    }
    .navbar .brand-header .logo {
        height: 2rem;
    }
    .navbar > .container {
        padding: 0;
    }
    .lead {
        background-color: #f2f2f2;
        color: #3d4a4c;
    }
    :global(body.fontloaded-montserratregular) .lead {
        font-family: 'montserratregular';
    }
    .lead > .container {
        padding-bottom: 1rem;
        padding-top: 1rem;
    }
    .lead .brand-header {
        display: none;
        text-decoration: none;
    }
    .lead-text {
        display: inline-block;
        font-size: 1.1rem;
        vertical-align: bottom;
        margin: 0;
    }
    .lead .brand-header .logo {
        height: 50px;
    }
    .report-error {
        color: #c2178a;
    }
    .report-error:hover {
        background-color: #c2178a;
        color: #FFF;
    }
    nav {
        /*border-bottom: 1px solid rgba(170,30,30,0.1);*/
        font-weight: 300;
        padding: 0;/* 1em;*/
    }
    .navbar > .container > nav >  ul {
        margin: 0;
        padding: 0;
        display: none;
    }
    .navbar > .container > nav > ul.opened {
        display: block;
    }
    .subnavbar ul {
        margin: 0;
        padding: 0;
    }
    .navbar li {
        display: block;
    }
    @media (min-width: 980px) {
        .navbar {
            overflow: visible;
        }
        .header {
            position: relative;
            display: inline-block;
            min-width: auto;
            width: auto;
            height: auto;
            border: none;
        }
        .subnavbar {
            position: fixed;
            top: 3rem;
            left: 0;
            width: 100%;
        }
        .navbar > .container > nav {
            margin-top: 0rem;
            float: right;
        }
        .navbar > .container >  nav > ul {
            float: right;
            display: block;
        }
        .navbar > .container >  nav > ul > li {
            float: left;
        }
        .navbar .brand-header {
            opacity: 0;
            height: 0;
            width: 0;
            overflow: hidden;
            transition: opacity 0.33s ease-in-out;
        }
        .navbar .menu {
            display: none;
        }
        .navbar .show.brand-header {
            height: auto;
            width: auto;
            opacity: 1;
        }
        .navbar > .container {
            padding-left: 2rem;
            padding-right: 2rem;
        }
        .lead .brand-header {
            display: inline-block;
        }
        .lead-text {
            font-size: 1.5rem;
            margin: 1rem 0 1rem 2rem;
        }
    }

    /* clearfix */
    ul::after {
        content: '';
        display: block;
        clear: both;
    }

    /* clearfix */
    nav::after {
        content: '';
        display: block;
        clear: both;
    }

    .selected {
        position: relative;
        display: inline-block;
    }

    /*.selected::after {
        position: absolute;
        content: '';
        width: calc(100% - 1em);
        height: 2px;
        background-color: rgb(170,30,30);
        display: block;
        bottom: -1px;
    }*/

    nav a, nav span {
        text-decoration: none;
        padding: 1em 1em;
        display: block;
        cursor: pointer;
    }
    nav .active, .subnavbar {
      background-color: #f2f2f2;
    }
    .submenu li {
      display: block;
    }
    .submenu a::after {
      content: '>';
      margin-left: 0.4rem;
    }
    .submenu li:hover {
      color: #00938f;
    }
</style>
