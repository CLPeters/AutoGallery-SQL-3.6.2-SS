<html>
<head>

<script language="JavaScript">

var search   = '##Search_Field##';
var order    = '##Order_Field##';
var start    = parseInt('##Start##');
var total    = parseInt('##Total##');
var per_page = parseInt('##Per_Page##');
var page     = parseInt('##Page##');
var end      = null;
var changed  = false;


function submitForm(page)
{
    document.search.Page.value = parseInt(document.search.Page.value) + parseInt(page);
    document.search.submit();

    return false;
}



function checkSelected(form)
{
    if( form.Run.value == 'EmailSelectedAccounts' )
    {
        var checked = false;

        for( var i = 0; i < form.elements.length; i++ )
        {
            if( form.elements[i].type == 'checkbox' && form.elements[i].checked )
            {
                checked = true;
            }
        }

        if( !checked )
        {
            alert('Please select at least one account to e-mail');
            return false;
        }
    }
}



function selectAll(form)
{
    var value = null;

    if( form.Select_All.value == 'Select All' )
    {
        form.Select_All.value = 'Deselect All';
        value = true;   
    }
    else
    {
        form.Select_All.value = 'Select All';
        value = false;
    }


    for( var i = 0; i < form.elements.length; i++ )
    {
        if( form.elements[i].type == 'checkbox' )
        {
            form.elements[i].checked = value;
        }
    }
}


function setupPage()
{
    var form    = document.search;
    var element = null;


    // Set selected state of search field
    for( i = 0; i < form.Search_Field.options.length; i++ )
    {
        if( form.Search_Field.options[i].value == search )
        {
            form.Search_Field.options[i].selected = true;
            break;
        }
    }


    // Set selected state of order field
    for( i = 0; i < form.Order_Field.options.length; i++ )
    {
        if( form.Order_Field.options[i].value == order )
        {
            form.Order_Field.options[i].selected = true;
            break;
        }
    }


    // Setup end and next
    end = (page+1) * per_page;

    if( total <= end )
    {
        end = total;

        element = document.getElementById('Next');

        if( element )
        {
            element.innerHTML = '';
        }
    }

    element = document.getElementById('End');

    if( element )
    {
        element.innerHTML = end;
    }


    // Setup prev
    if( page <= 0 )
    {
        element = document.getElementById('Prev');

        if( element )
        {
            element.innerHTML = '';
        }
    }
}



function showEdit(account)
{
    window.open('main.cgi?Run=DisplayEditAccount&Account_ID=' + account, 'account', 'menubar=no,height=475,width=725,scrollbars=no,top=300,left=300');
    return false;
}



function deleteAccount(account)
{
    var div = document.getElementById(account);

    if( !confirm("Are you sure you want to delete account '" + account + "'?") )
    {
        return false;
    }

    window.open('main.cgi?Run=DeleteAccount&Account_ID=' + account, '_blank', 'menubar=no,height=125,width=350,scrollbars=yes,top=300,left=300');

    // Mark the account as deleted
    var row_parent = div.parentNode;
        row_parent.removeChild(div);

    // If any accounts are deleted, set it so the Next link points
    // to the same page.  This way we don't skip any accounts.
    if( !changed )
    {
        changed = true;
        document.search.Page.value = parseInt(document.search.Page.value) - 1;
    }

    return false;
}



function newSearch(form)
{
    form.Page.value = 0;
}

</script>


<!--[Include File ./templates/admin.js]-->
<!--[Include File ./templates/admin.css]-->
</head>
<body class="mainbody" onLoad="setupPage();">

<!--[If Start Message]-->
<div id="message" class="message">
##Message##
</div>
<br />
<!--[If End]-->


<div style="width: 790px" align="center">


<!-- BEGIN SEARCH TABLE -->
<form name="search" action="main.cgi" method="POST">

<table class="outlined" width="500" cellspacing="0" cellpadding="3">
<tr>
<td colspan="3" align="center" class="menuhead">
Partner Accounts
</td>
</tr>

<tr>
<td align="right">
<b>Search In</b>
</td>
<td colspan="2">
<select name="Search_Field">
  <option value="Account_ID">Account ID</option>
  <option value="Email">E-mail</option>
  <option value="Password">Password</option>
</select>
</td>
</tr>

<tr>
<td align="right">
<b>Search Term</b>
</td>
<td colspan="2">
<input type="text" name="Search_Value" size="30" value="##Search_Value##">
</td>
</tr>

<tr>
<td align="right">
<b>Order By</b>
</td>
<td colspan="2">
<select name="Order_Field">
  <option value="Account_ID">Account ID</option>
  <option value="Email">E-mail</option>
  <option value="Password">Password</option>
  <option value="Weight DESC">Weight</option>
  <option value="Allowed DESC">Galleries Per Day</option>
  <option value="Submitted DESC">Submitted Galleries</option>
  <option value="Removed DESC">Removed Galleries</option>
  <option value="Start_Date DESC">Start Date</option>
  <option value="End_Date DESC">End Date</option>
</select>
</td>
</tr>


<tr>
<td align="right">
<b>Per Page</b>
</td>
<td colspan="2">
<input type="text" name="Per_Page" size="10" value="##Per_Page##">
</td>
</tr>


<tr>
<td width="200">
<span id="Prev">
<a href="" onClick="return submitForm(-1);">&lt;&lt; Prev</a>
</span>
</td>
<td width="100" align="center">
<input type="submit" value="Search" onClick="newSearch(document.search);">
<input type="hidden" name="Page" value="##Page##">
</td>
<td  width="200" align="right">
<span id="Next">
<a href="" onClick="return submitForm(1);">Next &gt;&gt;</a>
</span>
</td>
</tr>
</table>
<!-- END SEARCH TABLE -->

</div>

<input type="hidden" name="Run" value="DisplayAccounts">
</form>
<br />













<!-- START RESULTS TABLE -->
<!--[If Start Accounts]-->
<form name="form" action="main.cgi" method="POST" onSubmit="return checkSelected(this)">

<table class="outlined" width="790" cellspacing="0" cellpadding="3" border="0">
<tr>
<td colspan="6" align="center" class="menuhead">
Search Results ##Start## - <span id="End"></span>&nbsp;of ##Total##
</td>
</tr>

<tr bgcolor="#afafaf">
<td>
<b style="padding-left: 25px;">ID</b>
</td>
<td align="center">
<b>Sub/Rem</b>
</td>
<td align="center" width="60">
<b>Allowed</b>
</td>
<td align="center" width="60">
<b>Weight</b>
</td>
<td align="center">
<b>Dates</b>
</td>
<td align="center" width="75">
<b>Actions</b>
</td>
</tr>

<!--[Loop Start Accounts]-->
<!--[If Start Code {$i % 2 == 0}]-->
<tr bgcolor="#ececec" id="##Account_ID##">
<!--[If Else]-->
<tr bgcolor="#ffffff" id="##Account_ID##">
<!--[If End]-->

<td>
<input type="checkbox" name="Account_ID" value="##Account_ID##"> <a href="mailto:##Email##" id="##Account_ID##_ahref">##Account_ID##</a>
</td>
<td align="center" class="dotted-left">
<span id="##Account_ID##_submitted">##Submitted##</span>/<span id="##Account_ID##_removed">##Removed##</span>
</td>
<td align="center" width="60" class="dotted-left">
<span id="##Account_ID##_allowed">##Allowed##</span>
</td>
<td align="center" width="60" class="dotted-left">
<span id="##Account_ID##_weight">##Weight##</span>
</td>
<td align="center" width="200" class="dotted-left">
<span id="##Account_ID##_dates">##Dates##</span>
</td>
<td align="center" width="75" class="dotted-left">
<a href="" onClick="return showEdit('##Account_ID##');">[Edit]</a>
&nbsp;&nbsp;
<a href="" onClick="return deleteAccount('##Account_ID##');">[X]</a>
</td>
</tr>
<!--[Loop End]-->


</table>

<br />

<table class="outlined" width="790" cellspacing="0" cellpadding="3">
<tr>

<td width="33%" align="center">
<input type="button" name="Select_All" value="Select All" onClick="selectAll(document.form);">
</td>
<td width="33%" align="center">
<input type="submit" value="E-mail Selected" onClick="setRun('EmailSelectedAccounts');">
</td>
<td width="33%" align="center">
<input type="submit" value="E-mail All" onClick="setRun('EmailAllAccounts');">
<input type="hidden" name="Run">
</td>

</tr>
</table>

</form>
<!--[If Else]-->
<div align="center" style="width: 790px; color: red;">
<b>No Accounts Matched Your Search Criteria</b>
</div>
<br />
<!--[If End]-->
<!-- END RESULTS TABLE -->


</body>
</html>