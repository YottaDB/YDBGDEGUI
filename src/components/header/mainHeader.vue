<!--
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#   This source code contains the intellectual property         #
#   of its copyright holder(s), and is made available           #
#   under a license.  If you do not know the terms of           #
#   the license, please stop and do not read further.           #
#                                                               #
#################################################################
-->
<template>
<header id="header">
  <b-container id="main-header">
    <b-row id="navholder">
    <b-navbar toggleable id="main-nav">
      <b-navbar-brand href="/" id="main-logo">
        <img src="../../assets/img/YottaDB_logo.svg" alt="YottaDB">
      </b-navbar-brand>
      <b-nav-toggle target="nav_collapse"></b-nav-toggle>
      <b-collapse is-nav id="nav_collapse">
        <ul id="menu-main-menu" class="menu">
          <li v-for="menu in menus.main" :key="menu.name" class="menu-item menu-item-has-children">
            <router-link :to="menu.url" v-text="menu.name"></router-link>
            <ul class="sub-menu">
              <li v-for="submenu in menu.submenus" :key="submenu.name" class="menu-item">
                <router-link :to="submenu.url" v-text="submenu.name"></router-link>
              </li>
            </ul>
          </li>
        </ul>
      </b-collapse>
    </b-navbar>
  </b-row>
  </b-container>
</header>
</template>

<script>
export default {
  name: 'mainHeader',
  data() {
    return {
      menus: {
        main: [
          {
            name: 'System Administraton',
            url: '#',
            submenus: [
              {
                name: 'Global Directory Editor (GDE)',
                url: 'gde',
              },
              {
                name: 'Data Structure Editor (DSE)',
                url: '#',
              },
              {
                name: 'SQL Management',
                url: '#',
              },
              {
                name: 'Web Server',
                url: '#',
              },
              {
                name: 'Call-In Management',
                url: '#',
              },
              {
                name: 'Call-Out Management',
                url: '#',
              },
            ],
          },
          {
            name: 'Monitoring',
            url: '#',
            submenus: [
              {
                name: 'InfoHub',
                url: '#',
              },
              {
                name: 'gvstat',
                url: '#',
              },
              {
                name: 'Database Performance',
                url: '#',
              },
              {
                name: 'SQL Cached Queries',
                url: '#',
              },
              {
                name: 'Web Server',
                url: '#',
              },
            ],
          },
          {
            name: 'Resources',
            url: '#',
            submenus: [
              {
                name: 'Documentation',
                url: 'https://yottadb.com/resources/documentation/',
              },
            ],
          },
        ],
      },
    };
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
header{
    /*padding-top: 30px;*/
    background-color:#f3f3f3;
    position:fixed;
    top:0;
    left:0;
    width:100%;
    z-index:101;
    padding-bottom:15px;
    -ms-transition:.25s;
    -moz-transition:.25s;
    -o-transition:.25s;
    -webkit-transition:.25s;
    transition:.25s
}

#main-logo{
    margin-top:45px;
    -ms-transition:.25s;
    -moz-transition:.25s;
    -o-transition:.25s;
    -webkit-transition:.25s;
    transition:.25s
}
#main-logo img{
    width:200px;
    height:60px
}
.nav div ul,nav div ul{
    list-style-type:none;
    padding:0;
    margin:0
}
.nav div ul li,nav div ul li{
    list-style-type:none;
    margin:0;
    padding:0;
    display:inline-block
}
.nav div ul li a,nav div ul li a{
    display:block
}
#main-nav{
    padding-top:5px
}
#main-nav #menu-main-menu{
    top:4px;
    position:relative
}
#main-nav div ul{
    text-align:right;
    font-size:18px;
    text-transform:uppercase
}
#main-nav div ul li{
    display:inline-block;
    margin:0 20px;
    position:relative
}
#main-nav div ul li a{
    color:#3b1a68;
    font-weight:500;
    letter-spacing:.05em
}
#main-nav div ul li a:hover{
    color:#f77825;
    font-weight:500
}
#main-nav div ul li.menu-item-has-children::after{
    content:'';
    position:absolute;
    top:100%;
    left:0;
    height:15px;
    width:100%
}
#main-nav div ul li ul{
    display:none;
    position:absolute;
    top:calc(100% + 15px);
    z-index:10;
    white-space:nowrap;
    text-align:left;
    padding:20px 15px;
    left:-15px
}
#main-nav div ul li ul li{
    display:block;
    margin:0;
    margin-bottom:15px
}
#main-nav div ul li ul li:last-of-type{
    margin-bottom:0
}
#main-nav div ul li ul li a{
    color:#fff;
    letter-spacing:.05em;
    font-size:16px;
    text-transform:uppercase;
    font-weight:400
}
#main-nav div ul li ul li a:hover{
    color:#f77825;
    font-weight:400
}
#main-nav div ul li ul::after{
    content:'';
    position:absolute;
    top:calc(100% - 15px);
    left:0;
    width:100%;
    height:15px;
    -ms-transform:skewY(-2.5deg);
    -moz-transform:skewY(-2.5deg);
    -o-transform:skewY(-2.5deg);
    -webkit-transform:skewY(-2.5deg);
    transform:skewY(-2.5deg);
    transform-origin:100%;
    -webkit-transform-origin:100%;
    -moz-transform-origin:100%;
    z-index:-1;
    background-color:#3b1a68
}
#main-nav div ul li:hover ul{
    display:block;
    background-color:#3b1a68;
    border-right:1px solid #3b1a68
}
</style>
