<!--
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
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
  <div id="main_wrapper">
    <mainHeader/>
    <main class="main">
      <router-view/>
    </main>
    <!--   <mainFooter></mainFooter> -->
  </div>
</template>

<script>
import mainHeader from '@/components/header/mainHeader';
import mainFooter from '@/components/footer/mainFooter';

export default {
  name: 'App',
  components: { mainHeader, mainFooter },
};
</script>

<style>
body,html{
    font-size:20px;
    font-weight:400;
    font-family:Raleway Medium,sans-serif;
    line-height:normal;
    color:#595959;
    -webkit-font-smoothing:antialiased;
    -moz-osx-font-smoothing:grayscale;
    font-variant-numeric:lining-nums;
    -webkit-font-feature-settings:"lnum" 1,"liga" 0;
    -moz-font-feature-settings:"lnum" 1,"liga" 0;
    -ms-font-feature-settings:"lnum" 1,"liga" 0;
    font-feature-settings:"lnum" 1,"liga" 0
}
pre{
    width:100%;
    padding:5px;
    margin:5px 0;
    overflow:auto;
    overflow-y:hidden;
    font-size:14px;
    line-height:20px;
    background:#ddd;
    border-radius:5px;
    border:1px solid #777;
    font-family:Inconsolata,monospace
}
.fixed-width-font{
    font-family:Inconsolata,monospace
}
#main_wrapper{
    overflow-x:hidden
}
.main{
  margin-top:210px;
}
</style>
