{include file="header"}

<div class="edit-asset {$entrycode}">

	{if $asset['assetid']}
		<h2>
			<span class="assettype">
				<a href="/list/{$entrycode}">{$entryplural}</a>
			</span> /
			<span class="title">
				<a
					href="{if $asset['urlalias']}/{$asset['urlalias']}{else}/show/mod/{$asset['assetid']}{/if}">{$asset["name"]}</a>
			</span> /
			<span class="title">Edit</span>
		</h2>
	{else}
		<h2>
			<span class="assettype">
				<a href="/list/{$entrycode}">{$entryplural}</a>
			</span> /
			<span class="title">Add new {$entrysingular}</span>
		</h2>
	{/if}

	<form method="post" name="deleteform">
		<input type="hidden" name="at" value="{$user['actiontoken']}">
		<input type="hidden" name="delete" value="1">
	</form>

	<form method="post" name="form1">
		<input type="hidden" name="at" value="{$user['actiontoken']}">
		<input type="hidden" name="save" value="1">
		<input type="hidden" name="assetid" value="{$asset['assetid']}">
		<input type="hidden" name="numsaved" value="{$asset['numsaved']}">
		<input type="hidden" name="saveandback" value="0">

		<div class="editbox" style="min-height:54px;">
			<label><abbr title="Only mods with Status 'Published' are publicly visible">Status</abbr></label>
			<select name="statusid" style="width:120px;">
				{foreach from=$stati item=status}
					<option value="{$status['statusid']}" {if $asset['statusid']==$status['statusid']}selected="selected"
						{/if}>{$status['name']}</option>
				{/foreach}
			</select>
		</div>

		<div class="editbox" style="min-height:54px;">
			<label><abbr
					title="Only mods with type 'Game Mod' are available in the in-game mod browser">Type</abbr></label>
			<select name="type" style="width:120px;">
				{foreach from=$modtypes item=modtype}
					<option value="{$modtype['code']}" {if $asset['type']==$modtype['code']}selected="selected" {/if}>
						{$modtype['name']}</option>
				{/foreach}
			</select>
		</div>

		<div class="editbox">
			<label>Tags</label>
			<select name="tagids[]" style="width:300px;" multiple>
				{foreach from=$tags item=tag}
					<option value="{$tag['tagid']}" title="{$tag['text']}"
						{if !empty($asset['tags'][$tag['tagid']])}selected="selected" {/if}>{$tag['name']}</option>
				{/foreach}
			</select>
		</div>

		<div class="editbox linebreak">
			<label>Name</label>
			<input type="text" name="name" style="width: 400px;" class="required" value="{$asset['name']}" />
		</div>

		<div class="editbox" style="line-height:127%">
			<label><abbr
					title="If set, your mod can be reached with this custom url. Only alphabetical letters are allowed.">URL
					Alias</abbr></label>
			<span style="font-size:12px;">https://mods.vintagestory.at/</span><input type="text" name="urlalias"
				style="width: 80px;" value="{$asset['urlalias']}" />
		</div>

		<div class="editbox linebreak">
			<label>Summary. Describe your mod in 100 characters or less.</label>
			<input type="text" name="summary" style="width: 992px;" maxlength="100" class="required"
				value="{$asset['summary']}" />
		</div>
		<div class="editbox linebreak" style="width: 95%; min-width: 350px;">
			<label>Text</label>
			<textarea name="text" class="editor" data-editorname="text"
				style="width: 100%; height: auto;">{$asset['text']}</textarea>
		</div>

		{if file_exists("templates/edit-asset-$entrycode.tpl")}
			{include file="edit-asset-`$entrycode`.tpl"}
		{/if}

		{if isset($asset['createdbyuserid']) && ($asset['createdbyuserid'] == $user['userid']) || $asset['assetid'] === 0}
			<div style="clear:both;"></div>
			<h3>Team members</h3>

			{if $asset['assetid'] === 0}
				<p>Team members can be added after the mod has been created.</p>
			{else}
				<div class="editbox linebreak teammembers" style="min-height: 85px;">
					<label>Team Members</label>
					<select name="teammemberids[]" style="width:300px;" multiple class="teammembers ajax-autocomplete"
						data-url="/api/authors?name={name}"
						data-ownerid="{if $asset['assetid'] > 0}{$teammembers['ownerid']}{else}{$user['userid']}{/if}">
						{if isset($teammembers) && count($teammembers['members']) > 0 && $asset['assetid'] > 0}
							{foreach from=$teammembers['members'] item=teammember}
								<option selected {if $teammember['userid'] == $teammembers['ownerid']}disabled{/if}
									value="{$teammember['userid']}" title="{$teammember['name']}">
									{$teammember['name']}
								</option>
							{/foreach}
						{/if}
					</select>
				</div>
			{/if}

			{if (isset($teammembers) && count($teammembers['members']) > 0) && $asset['assetid'] > 0}
				<div class="editbox" style="min-height: 85px;">
					<label>Team Members with edit permissions</label>
					<select name="teammembereditids[]" style="width:300px;" multiple class="teammembers-edit">
						{foreach from=$teammembers['members'] item=teammember}
							<option {if $teammember['canedit'] == 1}selected{/if}
								{if $teammember['userid'] == $teammembers['ownerid']}disabled{/if} value="{$teammember['userid']}"
								title="{$teammember['name']}">
								{$teammember['name']}
							</option>
						{/foreach}
					</select>
				</div>
			{/if}
		{/if}

		<div style="clear:both;"></div>

		<h3>Screenshots<span style="float:right; font-size:70%;">(drag&drop to upload{if false /*:ZipDownloadDisabled*/ && (count($files) > 0)}, <a href="/download?assetid={$asset['assetid']}">download all as zip</a>{/if})</span></h3>

		{include file="edit-asset-files.tpl"}

		<div style="clear:both;"></div>
		<h3>Additional information</h3>


		<div class="editbox linebreak">
			<label>Homepage or Forum Post Url</label>
			<input type="text" name="homepageurl" style="width: 300px;" value="{$asset['homepageurl']}" />
		</div>

		<div class="editbox">
			<label>Trailer Video Url</label>
			<input type="text" name="trailervideourl" style="width: 300px;" value="{$asset['trailervideourl']}" />
		</div>

		<div class="editbox">
			<label>Source Code Url</label>
			<input type="text" name="sourcecodeurl" style="width: 300px;" value="{$asset['sourcecodeurl']}" />
		</div>

		<div class="editbox">
			<label>Issue tracker Url</label>
			<input type="text" name="issuetrackerurl" style="width: 300px;" value="{$asset['issuetrackerurl']}" />
		</div>

		<div class="editbox">
			<label>Wiki Url</label>
			<input type="text" name="wikiurl" style="width: 300px;" value="{$asset['wikiurl']}" />
		</div>

		<div class="editbox">
			<label>Donate Url</label>
			<input type="text" name="donateurl" style="width: 300px;" value="{$asset['donateurl']}" />
		</div>

		<div class="editbox linebreak">
			<label>Side</label>
			<select name="side">
				<option value="client" {if ($asset['side']=='client')}selected="selected" {/if}>Client side only mod
				</option>
				<option value="server" {if ($asset['side']=='server')}selected="selected" {/if}>Server side only mod
				</option>
				<option value="both" {if (empty($asset['side']) || $asset['side']=='both')}selected="selected" {/if}>
					Client and Server side mod</option>
			</select>
		</div>

		<div class="editbox">
			<label>Logo/Thumbnail image</label>
			<select name="logofileid" style="width:250px;">
				{foreach from=$files item=file}
					<option value="{$file['fileid']}" {if $asset['logofileid']==$file['fileid']} selected="selected" {/if}>
						{$file['filename']}</option>
				{/foreach}
			</select>
		</div>

		{if isset($asset['createdbyuserid']) && ($asset['createdbyuserid'] == $user['userid'])}
			<div style="clear:both;"></div>
			<h3>Ownership transfer</h3>

			<div class="editbox linebreak ownership">
				{if isset($ownershipTransferUser) && $ownershipTransferUser}
					<span>An ownership transfer invitation has been sent to: {$ownershipTransferUser}.</span>
					<br>
					<span>You may revoke the pending invitation using the button below:</span>
					<p><a href="/edit/mod/?assetid={$asset['assetid']}&revokenewownership=1" class="button btndelete">REVOKE</a></p>
				{else}
					<div>
						<label>Select new owner</label>
						<small>Ownership can only be transferred by the current owner of this resource.</small>
						<br>
						<small>A notification will be sent to the specified user, inviting them to accept ownership.</small>
						<br>

						<select class="ownership" name="newownerid" style="width:300px;"class="teammembers ajax-autocomplete"
							data-url="/api/authors?name={name}"
							data-ownerid="{if $asset['assetid'] > 0}{$teammembers['ownerid']}{else}{$user['userid']}{/if}">
						>
							<option value="" selected="selected">--- Select new owner ---</option>
						</select>
					</div>
				{/if}

			</div>
		{/if}
</div>

<div class="file template">
	<input type="hidden" name="fileids[]" value="" />
	<a href="#" class="editbox">
		<div class="fi">
			<div class="fi-content"></div>
		</div>
		<img src="" style="display:none;" />
		<div class="filename"></div><br>
		<div class="uploaddate"></div><br>
		<div class="uploadprogress"></div>
	</a>
</div>

<div class="connection template editbox" style="clear:both;">
	<input type="hidden" name="connectionid[]" value="">
	<select name="connectiontypeid[]" class="required" style="width:150px;">
		{foreach from=$connectiontypes item=connectiontype}
			<option value="{$connectiontype['connectiontypeid']}">{$connectiontype['name']}</option>
		{/foreach}
	</select>

	<select name="assettypeid[]" class="required" style="width: 150px">
		<option value="">-</option>
		{foreach from=$assettypes item=assettype}
			<option value="{$assettype['assettypeid']}">{$assettype['name']}</option>
		{/foreach}
	</select>

	<select name="toassetid[]" class="required" style="width: 300px">
	</select>

	<a href="#" class="delete"></a>
</div>

<p style="clear:both;"><br></p>

{include
	file="submitbutton"
	href="javascript:submitForm(0)"
	buttontext="Save"
}

{if $asset['assetid'] && canDeleteAsset($asset, $user)}
	<span style="float:right;">
		{include
			file="button"
			class="btndelete"
			href="javascript:submitDelete()"
			buttontext="Delete `$entrysingular`"
		}
	</span>
{/if}

<p style="clear:both;"><br></p>


{capture name="footerjs"}
	<script type="text/javascript">
		$(document).ready(function() {
			$('form[name=commentformtemplate]').areYouSure();
		});
	</script>	

	<script type="text/javascript" src="/web/js/edit-asset.js?version=28" async></script>
{/capture}

{include file="footer"}