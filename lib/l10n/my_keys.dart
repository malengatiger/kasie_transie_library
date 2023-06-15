
import 'dart:collection';

class MyKeys {
  static var hashMap = HashMap<String, String>();
  static HashMap getKeys() {
    if (hashMap.isEmpty) {
      _buildMap();
    }
    return hashMap;
  }

  static _buildMap() {
    hashMap["enterRateInMinutes"] = "Enter the number of minutes for data refresh";
    hashMap["refreshRateInMinutes"] = "Refresh Rate In Minutes";

    hashMap["upgrade"] = "upgrade";
    hashMap["upgradeText"] = "upgradeText";
    hashMap["payment"] = "payment";
    hashMap["subscriptionPlans"] = "subscriptionPlans";
    hashMap["subscriptionPayment"] = "subscriptionPayment";
    hashMap["contract"] = "contract";
    
    hashMap["freeDesc"] = "freeDesc";
    hashMap["monthlyDesc"] = "monthlyDesc";
    hashMap["annualDesc"] = "annualDesc";
    hashMap["corporateDesc"] = "corporateDesc";
    hashMap["confirm"] = "confirm";
    hashMap["errorTrans"] = "errorTrans";
    hashMap["submitText"] = "submitText";

    hashMap["subscriptionPlans"] = "subscriptionPlans";
    hashMap["selectPlan"] = "selectPlan";
    hashMap["freeSub"] = "freeSub";
    hashMap["monthly"] = "monthly";
    hashMap["annual"] = "annual";
    hashMap["corporate"] = "corporate";
    hashMap["free"] = "free";
    hashMap["paymentReceived"] = "paymentReceived";
    hashMap["thanksForSub"] = "thanksForSub";

    hashMap["enrolledFree"] = "enrolledFree";

    hashMap["subscriptionSubTitle"] = "subscriptionSubTitle";
    
    
    hashMap["subscriptionSubTitle"] = "subscriptionSubTitle";
    hashMap["saveProjectLocation"] = "saveProjectLocation";
    hashMap["latitude"] = "latitude";
    hashMap["longitude"] = "longitude";
    hashMap["areaPoint"] = "areaPoint";
    hashMap["ratingAddedThanks"] = "ratingAddedThanks";
    hashMap["selectProject"] = "selectProject";
    hashMap["videoAddedThanks"] = "videoAddedThanks";
    hashMap["audioAddedThanks"] = "audioAddedThanks";
    hashMap["photoAddedThanks"] = "photoAddedThanks";
    hashMap["projectAddedThanks"] = "projectAddedThanks";
    hashMap["memberAddedThanks"] = "memberAddedThanks";
    hashMap["settingsAddedThanks"] = "settingsAddedThanks";
    hashMap["ratingAddedThanks"] = "ratingAddedThanks";


    hashMap["searchProjects"] = "searchProjects";
    hashMap["search"] = "search";
    hashMap["searchMembers"] = "Search Members";
    hashMap["searchUsers"] = "Search Users";
    hashMap["closeCancel"] = "Close/Cancel";
    hashMap["exit"] = "Exit";
    hashMap["timeLine"] = "timeLine";
    hashMap["projectTimeline"] = "projectTimeline";
    hashMap["seeLocationDetails"] = "seeLocationDetails";
    hashMap["ratePhoto"] = "ratePhoto";
    hashMap["createdBy"] = "createdBy";
    hashMap["rateVideo"] = "rateVideo";
    hashMap["rateAudio"] = "rateAudio";

    hashMap["actionsOnPhoto"] = "actionsOnPhoto";
    hashMap["actionsOnVideo"] = "actionsOnVideo";
    hashMap["actionsOnAudio"] = "actionsOnAudio";

    hashMap["close"] = "close";
    hashMap["cancel"] = "close";

    hashMap["loadingData"] = "loadingData";
    hashMap["recentEvents"] = "recentEvents";
    hashMap["events"] = "events";
    hashMap["recentEvents"] = "recentEvents";
    hashMap["audioArrived"] = "audioArrived";
    hashMap["photoArrived"] = "photoArrived";
    hashMap["videoArrived"] = "videoArrived";

    hashMap["locationRequestArrived"] = "locationRequestArrived";
    hashMap["locationResponseArrived"] = "locationResponseArrived";

    hashMap["memberAddedChanged"] = "memberAddedChanged";

    hashMap["projectAdded"] = "projectAdded";
    hashMap["settingsArrived"] = "settingsArrived";

    hashMap["projectAreaAdded"] = "projectAreaAdded";
    hashMap["projectPositionAdded"] = "projectPositionAdded";

    hashMap["geoRunning"] = "geoRunning";
    hashMap["tapToReturn"] = "tapToReturn";
    hashMap["messageFromGeo"] = "messageFromGeo";
    hashMap["weHelpYou"] = "weHelpYou";
    hashMap['november'] = 'november';
    hashMap['projects'] = 'projects';
    hashMap['callMember'] = 'callMember';
    hashMap['addProjectLocations'] = 'addProjectLocations';
    hashMap['videos'] = 'videos';
    hashMap['administratorsMembers'] = 'administratorsMembers';
    hashMap["projectAreas"] = "projectAreas";
    hashMap["areas"] = "areas";
    hashMap['photos'] = 'photos';
    hashMap['april'] = 'april';
    hashMap['organizationMembers'] = 'organizationMembers';
    hashMap['executive'] = 'executive';
    hashMap['emailAddress'] = 'emailAddress';
    hashMap['profilePhoto'] = 'profilePhoto';
    hashMap['activityTitle'] = 'activityTitle';
    hashMap['members'] = 'members';
    hashMap['maximumVideoLength'] = 'maximumVideoLength';
    hashMap['selectProjectIfNecessary'] = 'selectProjectIfNecessary';
    hashMap['descriptionOfProject'] = 'descriptionOfProject';
    hashMap['submitProject'] = 'submitProject';
    hashMap['settings'] = 'settings';
    hashMap['august'] = 'august';
    hashMap['fieldMonitorInstruction'] = 'fieldMonitorInstruction';
    hashMap['audioClips'] = 'audioClips';
    hashMap['july'] = 'july';
    hashMap['refreshProjectDashboardData'] = 'refreshProjectDashboardData';
    hashMap['tapForColorScheme'] = 'tapForColorScheme';
    hashMap['organizationProjects'] = 'organizationProjects';
    hashMap['removeMember'] = 'removeMember';
    hashMap['newMember'] = 'newMember';
    hashMap['signInFailed'] = 'signInFailed';
    hashMap['organizationDashboard'] = 'organizationDashboard';
    hashMap['addProjectAreas'] = 'addProjectAreas';
    hashMap['name'] = 'name';
    hashMap['organizationRegistered'] = 'organizationRegistered';
    hashMap['october'] = 'october';
    hashMap['activityStreamHours'] = 'activityStreamHours';
    hashMap['submitMember'] = 'submitMember';
    hashMap['projectName'] = 'projectName';
    hashMap['projectDashboard'] = 'projectDashboard';
    hashMap['internetConnectionNotAvailable'] =
        'internetConnectionNotAvailable';
    hashMap['fieldMonitor'] = 'fieldMonitor';
    hashMap['photosVideosAudioClips'] = 'photosVideosAudioClips';
    hashMap['editMember'] = 'editMember';
    hashMap['sendMemberMessage'] = 'sendMemberMessage';
    hashMap['maximumAudioLength'] = 'maximumAudioLength';
    hashMap['administrator'] = 'administrator';
    hashMap['september'] = 'september';
    hashMap['schedules'] = 'schedules';
    hashMap['december'] = 'december';
    hashMap['cellphone'] = 'cellphone';
    hashMap['selectSizePhotos'] = 'selectSizePhotos';
    hashMap['requestMemberLocation'] = 'requestMemberLocation';
    hashMap['editProject'] = 'editProject';
    hashMap['may'] = 'may';
    hashMap['february'] = 'february';
    hashMap['maximumMonitoringDistance'] = 'maximumMonitoringDistance';
    hashMap['march'] = 'march';
    hashMap['registerOrganization'] = 'registerOrganization';
    hashMap['june'] = 'june';
    hashMap['projectLocationsMap'] = 'projectLocationsMap';
    hashMap['january'] = 'january';
    hashMap['pleaseSelectCountry'] = 'pleaseSelectCountry';
    hashMap['locations'] = 'locations';
    hashMap['addProjectLocationHere'] = 'addProjectLocationHere';
    hashMap['dashboardSubTitle'] = 'dashboardSubTitle';
    hashMap['numberOfDaysForDashboardData'] = 'numberOfDaysForDashboardData';
    hashMap['directionsToProject'] = 'directionsToProject';
    hashMap['welcomeToGeo'] = 'welcomeToGeo';
    hashMap['endDate'] = 'endDate';
    hashMap['sendCode'] = 'sendCode';
    hashMap['locationNotAvailable'] = 'locationNotAvailable';
    hashMap['weGotAProblem'] = 'weGotAProblem';
    hashMap['numberOfDays'] = 'numberOfDays';
    hashMap['projectDetails'] = 'projectDetails';
    hashMap['dataRefreshFailed'] = 'dataRefreshFailed';
    hashMap['projectLocationFailed'] = 'projectLocationFailed';
    hashMap['duration'] = 'duration';
    hashMap['updateFailed'] = 'updateFailed';
    hashMap['audioPlayer'] = 'audioPlayer';
    hashMap['projectActivities'] = 'projectActivities';
    hashMap['projectAddedToOrganization'] = 'projectAddedToOrganization';
    hashMap['verifyPhoneNumber'] = 'verifyPhoneNumber';
    hashMap['fieldMonitorSchedules'] = 'fieldMonitorSchedules';
    hashMap['projectsNotFound'] = 'projectsNotFound';
    hashMap['projectAudio'] = 'projectAudio';
    hashMap['videoBuffering'] = 'videoBuffering';
    hashMap['notReadyYet'] = 'notReadyYet';
    hashMap['userCreateFailed'] = 'userCreateFailed';
    hashMap['createAudioClip'] = 'createAudioClip';
    hashMap['phoneNumber'] = 'phoneNumber';
    hashMap['fileSize'] = 'fileSize';
    hashMap['memberDashboard'] = 'memberDashboard';
    hashMap['projectEditor'] = 'projectEditor';
    hashMap['startDate'] = 'startDate';
    hashMap['memberCreateFailed'] = 'memberCreateFailed';
    //
    hashMap["small"] = "small";
    hashMap["selectLanguage"] = "selectLanguage";
    hashMap["maxAudioLength"] = "maxAudioLength";
    hashMap["pleaseEnterVideoLength"] = "pleaseEnterVideoLength";
    hashMap["large"] = "large";
    hashMap["enterVideoLength"] = "enterVideoLength";
    hashMap["pleaseNumberOfDays"] = "pleaseNumberOfDays";
    hashMap["dashNumberOfDays"] = "dashNumberOfDays";
    hashMap["medium"] = "medium";
    hashMap["enterDistance"] = "enterDistance";
    hashMap["pleaseSelectLanguage"] = "pleaseSelectLanguage";
    hashMap["pleaseActivityStreamHours"] = "pleaseActivityStreamHours";
    hashMap["at"] = "at";
    hashMap["arrivedAt"] = "arrivedAt";
    hashMap["pleaseEnterDistance"] = "pleaseEnterDistance";
    hashMap["leftFrom"] = "leftFrom";
    hashMap["loadingActivities"] = "loadingActivities";
    hashMap["maxVideoLength"] = "maxVideoLength";
    hashMap["activityStreamHours"] = "activityStreamHours";
    hashMap["dashboard"] = "dashboard";

    //
    hashMap["selectPhotoSize"] = "selectPhotoSize";
    hashMap["fr"] = "fr";
    hashMap["en"] = "en";
    hashMap["es"] = "es";
    hashMap["af"] = "af";
    hashMap["pt"] = "pt";
    hashMap["zu"] = "zu";
    hashMap["sn"] = "sn";
    hashMap["sw"] = "sw";
    hashMap["ts"] = "ts";
    hashMap["st"] = "st";
    hashMap["yo"] = "yo";
    hashMap["ig"] = "ig";
    hashMap['xh'] = 'xh';
    hashMap['de'] = 'de';
    hashMap['zh'] = 'zh';
    hashMap['male'] = 'male';
    hashMap['female'] = 'female';
    hashMap["noActivities"] = "noActivities";
    hashMap["tapToRefresh"] = "tapToRefresh";
    hashMap["loadingActivities"] = "loadingActivities";
    hashMap["projectsNotFound"] = "projectsNotFound";
    hashMap["newProject"] = "newProject";
    hashMap["enterProjectName"] = "enterProjectName";
    hashMap["enterDescription"] = "enterDescription";
    hashMap["settingsChanged"] = "settingsChanged";
    hashMap["projectAdded"] = "projectAdded";
    hashMap["projectLocationAdded"] = "projectLocationAdded";
    hashMap["projectAreaAdded"] = "projectAreaAdded";
    hashMap["memberAtProject"] = "memberAtProject";
    hashMap["memberAddedChanged"] = "memberAddedChanged";
    hashMap["enterFullName"] = "enterFullName";
    hashMap["enterEmail"] = "enterEmail";
    hashMap["enterCell"] = "enterCell";
    hashMap["submitMember"] = "submitMember";
    hashMap["profilePhoto"] = "profilePhoto";
    hashMap['memberLocationResponse'] = 'memberLocationResponse';
    hashMap["South Africa"] = "South Africa";
    hashMap["Zimbabwe"] = "Zimbabwe";
    hashMap["Mozambique"] = "Mozambique";
    hashMap["Namibia"] = "Namibia";
    hashMap["Botswana"] = "Botswana";
    hashMap["Kenya"] = "Kenya";
    hashMap["Nigeria"] = "Nigeria";
    hashMap["Democratic Republic of Congo"] = "Democratic Republic of Congo";
    hashMap["Angola"] = "Angola";

    hashMap["conditionAdded"] = "conditionAdded";

    hashMap["stopMessage"] = "stopMessage";
    hashMap["restartMessage"] = "restartMessage";
    hashMap["stop"] = "stop";
    hashMap["cancel"] = "cancel";
    hashMap["restart"] = "restart";

    hashMap["projectLocationsAreas"] = "projectLocationsAreas";
    hashMap["projectMonitoringAreas"] = "projectMonitoringAreas";
    hashMap["organizationLocationsAreas"] = "organizationLocationsAreas";
    hashMap["location"] = "location";
    hashMap["area"] = "area";
    hashMap["noPhotosInProject"] = "noPhotosInProject";
    hashMap["noAudioInProject"] = "noAudioInProject";
    hashMap["noVideosInProject"] = "noVideosInProject";
    hashMap["settingSaved"] = "settingSaved";
    hashMap["appInfo"] = "appInfo";
    hashMap["whatGeoDo"] = "whatGeoDo";
    hashMap["geoForOrg"] = "geoForOrg";
    hashMap["geoForManagers"] = "geoForManagers";
    hashMap["infoForManagers"] = "infoForManagers";
    hashMap["infoForMonitors"] = "infoForMonitors";
    hashMap["howToStart"] = "howToStart";
    hashMap["thankYou"] = "thankYou";
    hashMap["thankYouMessage"] = "thankYouMessage";
    hashMap["networkUnavailable"] = "networkUnavailable";
    hashMap["messageReceived"] = "messageReceived";

    hashMap["takePicture"] = "takePicture";
    hashMap["takePhoto"] = "takePhoto";
    hashMap["elapsedTime"] = "elapsedTime";
    hashMap["recordAudioClip"] = "recordAudioClip";
    hashMap["playAudioClip"] = "playAudioClip";
    hashMap["uploadAudioClip"] = "uploadAudioClip";
    hashMap["playVideo"] = "playVideo";
    hashMap["recordVideo"] = "recordVideo";
    hashMap["uploadVideo"] = "uploadVideo";

    hashMap["projectAreas2"] = "projectAreas2";
    hashMap["projectLocatedHere"] = "projectLocatedHere";
    hashMap["projectMultipleLocations"] = "projectMultipleLocations";
    hashMap["projectAreas"] = "projectAreas";
    hashMap["refreshData"] = "refreshData";

    hashMap["gettingCameraReady"] = "gettingCameraReady";
    hashMap["recordingComplete"] = "recordingComplete";
    hashMap["recordingLimitReached"] = "recordingLimitReached";
    hashMap["duration"] = "duration";
    hashMap["fileSavedWillUpload"] = "fileSavedWillUpload";
    hashMap["problemWithCamera"] = "problemWithCamera";
    hashMap["locationRequestReceived"] = "locationRequestReceived";
    hashMap["locationResponseReceived"] = "locationResponseReceived";

    hashMap["memberArrivedAtProject"] = "memberArrivedAtProject";
    hashMap["memberLeftProject"] = "memberLeftProject";
    hashMap["organizationActivity"] = "organizationActivity";

    hashMap["memberActivity"] = "memberActivity";
    hashMap["projectActivity"] = "projectActivity";

    hashMap["infrastructure"] = "infrastructure";
    hashMap["govt"] = "govt";
    hashMap["youth"] = "youth";
    hashMap["community"] = "community";

    hashMap["managementPeople"] = "managementPeople";
    hashMap["fieldWorkers"] = "fieldWorkers";
    hashMap["executives"] = "executives";
    hashMap["organizations"] = "organizations";
    hashMap["information"] = "information";
    hashMap["government"] = "government";
    hashMap["thankYou"] = "thankYou";
    hashMap["communityTitle"] = "communityTitle";
    hashMap["thankYouMessage"] = "thankYouMessage";

    hashMap["videoToBeUploaded"] = "videoToBeUploaded";
    hashMap["photoToBeUploaded"] = "photoToBeUploaded";
    hashMap["audioToBeUploaded"] = "audioToBeUploaded";
    hashMap["videoLimitReached"] = "videoLimitReached";
    hashMap["audioLimitReached"] = "audioLimitReached";
    hashMap["welcomeAboard"] = "welcomeAboard";

    hashMap["videosNotFoundInProject"] = "videosNotFoundInProject";
    hashMap["photosNotFoundInProject"] = "photosNotFoundInProject";
    hashMap["audiosNotFoundInProject"] = "audiosNotFoundInProject";
    hashMap["projectsNotFoundInOrg"] = "projectsNotFoundInOrg";

    hashMap["networkProblem"] =  "networkProblem";
    hashMap["serverProblem"] =  "serverProblem";
    hashMap["createProject"] =  "createProject";
    hashMap["createOrg"] =  "createOrg";
    hashMap["checkNetworkSettings"] =  "checkNetworkSettings";
    hashMap["createMembers"] =  "createMembers";
    hashMap["portraitMode"] = "portraitMode";

    hashMap["waitingToRecordAudio"] = "waitingToRecordAudio";
    hashMap["waitingToRecordVideo"] = "waitingToRecordVideo";

    hashMap["createdAt"] = "createdAt";
    hashMap["createdBy"] = "createdBy";

    hashMap["addAudioRating"] =  "Add Audio Rating";
    hashMap["addVideoRating"] =  "Add Video Rating";
    hashMap["addPhotoRating"] =  "Add Photo Rating";
    hashMap["audioRatings"] =  "Audio Clip Ratings";
    hashMap["videoRatings"] =  "Video Ratings";
    hashMap["photoRatings"] =  "Photo Ratings";
    hashMap["errorRecording"] = "errorRecording";

    hashMap["memberArrived"] = "memberArrived";
    hashMap["memberLeft"] = "memberLeft";

    hashMap["schedules"] = "Schedules";
    hashMap["monitorSchedules"] = "monitorSchedules";
    hashMap["serverNotAvailable"] = "serverNotAvailable";
    hashMap["checkSettings"] = "checkSettings";
    hashMap["createNewProject"] = "createNewProject";
    hashMap["addNewMembers"] = "addNewMembers";

    hashMap["maxVideoLessThan"] =  "maxVideoLessThan";
    hashMap["maxAudioLessThan"] =  "maxAudioLessThan";
    hashMap["initializing"] = "initializing";

    hashMap["pleaseSelectGender"] = "pleaseSelectGender";
    hashMap["pleaseSelectType"] = "pleaseSelectType";
    hashMap["memberCreated"] = "memberCreated";
    hashMap["memberCreateFailed"] = "memberCreateFailed";
    hashMap["memberUpdateFailed"] = "memberUpdateFailed";

    hashMap["Democratic Republic of Congo"] = "Democratic Republic of Congo";
    hashMap["Lesotho"] = "Lesotho";
    hashMap["Eswatini"] = "Eswatini";

    hashMap["signIn"] = "signIn";
    hashMap["memberSignedIn"] = "memberSignedIn";
    hashMap["putInCode"] = "putInCode";
    hashMap["duplicateOrg"] = "duplicateOrg";
    hashMap["memberNotExist"] = "memberNotExist";
    hashMap["serverUnreachable"] = "serverUnreachable";
    hashMap["phoneSignIn"] = "phoneSignIn";
    hashMap["phoneAuth"] = "phoneAuth";
    hashMap["enterPhone"] = "enterPhone";
    hashMap["phoneNumber"] = "phoneNumber";

    hashMap["verifyPhone"] = "verifyPhone";
    hashMap["enterSMS"] = "enterSMS";
    hashMap["sendCode"] = "sendCode";
    hashMap["verifyComplete"] = "verifyComplete";
    hashMap["verifyFailed"] = "verifyFailed";
    hashMap["enterOrg"] = "enterOrg";

    hashMap["orgName"] = "orgName";

    hashMap["enterAdmin"] = "enterAdmin";
    hashMap["adminName"] = "adminName";
    hashMap["enterEmail"] = "enterEmail";
    hashMap["emailAddress"] = "emailAddress";

    hashMap["photoLocation"]  = "photoLocation";
    hashMap["videoLocation"]  = "videoLocation";
    hashMap["audioLocation"]  = "audioLocation";
    hashMap["memberLocation"]  = "memberLocation";

    hashMap["enterPassword"] = "enterPassword";
    hashMap["password"] = "password";
    hashMap["signInOK"] = "signInOK";

    hashMap["phoneAuth"] = "phoneAuth";
    hashMap["emailAuth"] = "emailAuth";
    hashMap["signInInstruction"] = "signInInstruction";

    hashMap["memberProfilePicture"] = "memberProfilePicture";
    hashMap["useCamera"] = "memberProfilePicture";
    hashMap["pickFromGallery"] = "pickFromGallery";
    hashMap["profileInstruction"] = "profileInstruction";
    hashMap["memberProfileUploaded"] = "memberProfileUploaded";
    hashMap["memberProfileUploadFailed"] = "memberProfileUploadFailed";

    hashMap["uploadMemberBatchFile"] = "uploadMemberBatchFile";
    hashMap["pickMemberBatchFile"] = "pickMemberBatchFile";
    hashMap["memberUploadFailed"] = "memberUploadFailed";
    hashMap["downloadExampleFiles"] = "downloadExampleFiles";
    hashMap["uploadInstruction"] = "uploadInstruction";
  }
}
