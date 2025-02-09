<?php

class ModEditor extends AssetEditor {
	
	
	function __construct() {
		$this->editTemplateFile = "edit-mod";
		
		parent::__construct("mod");

		$this->namesingular = "Mod";
		$this->nameplural = "Mods";
		
		$this->declareColumn(3, array("title" => "Homepage url", "code" => "homepageurl", "datatype" => "url", "tablename" => "mod"));
		$this->declareColumn(4, array("title" => "Source code url", "code" => "sourcecodeurl", "datatype" => "url", "tablename" => "mod"));
		$this->declareColumn(5, array("title" => "Trailer video url", "code" => "trailervideourl", "datatype" => "url", "tablename" => "mod"));
		$this->declareColumn(6, array("title" => "Issue tracker url", "code" => "issuetrackerurl", "datatype" => "url", "tablename" => "mod"));
		$this->declareColumn(7, array("title" => "Wiki url", "code" => "wikiurl", "datatype" => "url", "tablename" => "mod"));
		$this->declareColumn(13, array("title" => "Donate url", "code" => "donateurl", "datatype" => "url", "tablename" => "mod"));
		$this->declareColumn(8, array("title" => "Side", "code" => "side", "tablename" => "mod"));
		$this->declareColumn(9, array("title" => "Logo image", "code" => "logofileid", "tablename" => "mod"));
		$this->declareColumn(10, array("title" => "Mod Type", "code" => "type", "tablename" => "mod"));
		$this->declareColumn(11, array("title" => "URL Alias", "code" => "urlalias", "tablename" => "mod"));
		$this->declareColumn(12, array("title" => "Summary", "code" => "summary", "tablename" => "mod", "datatype" => "name"));
	}
	
	function load() {
		global $view;
		
		parent::load();
		
		$view->assign("modtypes", array(
			array('code' => "mod", "name" => "Game mod"),
			array('code' => "externaltool", "name" => "External tool"),
			array('code' => "other", "name" => "Other"),
		));
		
		if (!$this->assetid) {
			$this->asset['type'] = 'mod';
		}
	}
	
	function delete() {
		global $con;
		$modid = $con->getOne("select modid from `mod` where assetid=?", array($this->assetid));
		$con->Execute("delete from `release` where modid=?", array($modid));
		parent::delete();
	}
	
	function saveFromBrowser() {
		global $con, $view, $typewhitelist;
		
		$_POST['summary'] = substr(strip_tags($_POST['summary']), 0, 100);
		
		$_POST['urlalias'] = preg_replace("/[^a-z]+/", "", strtolower($_POST['urlalias']));
		if (!empty($_POST['urlalias'])) {
			if ($con->getOne("select modid from `mod` where urlalias=? and assetid!=?", array($_POST['urlalias'], $this->assetid))) {
				$view->assign("errormessage", "Not saved. This url alias is already taken. Please choose another.");
				return 'error';
			}
			
			if (in_array($_POST['urlalias'], $typewhitelist)) {
				$view->assign("errormessage", "Not saved. This url alias is reserved word. Please choose another.");
				return 'error';
			}
		}
		
		$modid = $con->getOne("select modid from `mod` where assetid=?", array($this->assetid));
		$hasfiles = $con->getOne("select releaseid from `release` where modid=?", array($modid));
		$statusreverted = false;
		if ($_POST['statusid'] != 1 && !$hasfiles) {
			$statusreverted = true;
			$_POST['statusid']=1;
		}
		
		$oldlogofileid = $con->getOne("select logofileid from `mod` where assetid=?", array($this->assetid));
		$result = parent::saveFromBrowser();
		$newlogofileid = $con->getOne("select logofileid from `mod` where assetid=?", array($this->assetid));
		
		if ($newlogofileid != $oldlogofileid) {
			$this->generateLogoImage($newlogofileid);
		}
		
		if ($this->isnew) {
			$con->Execute("update `mod` set lastreleased=now() where assetid=?", array($this->assetid));
		}
		
		if ($statusreverted) {
			$view->unsetVar("okmessage");
			$view->assign("warningmessage", "Changes saved, but your mod remains in 'Draft' status. You must upload a playable mod/tool first.");
			return "error";
		}

		return $result;
	}
	
	function generateLogoImage($logofileid) {
		global $con, $user;
		
		$file = $con->getRow("select * from file where fileid=?", array($logofileid));
		if (empty($file)) return;

		$locallogofilename = tempnam(sys_get_temp_dir(), $file['filename'].'.55_60');

		// Since we don't have teh files locally anymore we unfortunately have to do this stunt and re-download the image thats supposed to be used as a logo.
		// Upload happens asynchronously during drag-n-drop, so when the user saves the asset the files already don't exist locally anymore.
		// Since changing the logo is not a action repeated very often this is ok for now, especially since the alternative would be to keep files around, but not abandon them if hte user just navigates away from the asset editor.
		//TODO(Rennorb): @perf: Find a way to do this without re-downloading the image.

		$localpath = tempnam(sys_get_temp_dir(), '');
		$originalfile = @file_get_contents(formatUrl($file));
		if(!file_put_contents($localpath, $originalfile)) {
			unlink($localpath);
			return array("status" => "error", "errormessage" => 'The logo file seems to be gone.');
		}

		$resizeresult = copyImageResized($localpath, 480, 320, true, 'file', '', $locallogofilename);
		if(!$resizeresult) {
			unlink($localpath);
			return array("status" => "error", "errormessage" => 'Failed to resize image for thumbnail.');
		}

		splitOffExtension($file['cdnpath'], $cdnbasepath, $ext);

		$cdnlogopath = "{$cdnbasepath}_480_320.{$ext}";
		$uploadresult = uploadToCdn($locallogofilename, $cdnlogopath);
		unlink($locallogofilename);
		if($uploadresult['error']) {
			unlink($localpath);
			return array("status" => "error", "errormessage" => 'CDN Error: '.$uploadresult['error']);
		}

		$con->Execute("insert into file (userid, cdnpath, created) VALUES (?, ?, NOW())", array($user['userid'], $cdnlogopath));
		$con->Execute("update `mod` set logofileid=? where assetid=?", array($con->insert_ID(), $this->assetid));
	}
}
