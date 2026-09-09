# Énumérations et champs protobuf — `com.qiwu.worldwide.ride-8.06.42-base.apk`

> Extrait le 08/09/2026 à 01:00 par `tools/dump-proto-enums.py`.
> Filtre : `com/igpsport/blelib`

## Énumérations

### `AlgGmData$LIB_GM_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `LIB_GM_OPERATE_TYPE_INVALID` | **1** |
| `LIB_GM_OPERATE_TYPE_GET` | **2** |

### `AppWatch$WATCH_CONTROL_SERVICE`

| Constante | Valeur |
|---|---|
| `WCS_DEVICE_INFO` | **1** |
| `WCS_ADV_CONTROL` | **2** |

### `Back$AGPS_TYPE`

| Constante | Valeur |
|---|---|
| `enum_AGPS_FILE_TYPE_INVALID` | **0** |
| `enum_AGPS_FILE_TYPE_ONLINE` | **1** |
| `enum_AGPS_FILE_TYPE_ANO_OFFLINE` | **2** |
| `enum_AGPS_FILE_TYPE_ALM_OFFLINE` | **3** |

### `Back$BACK_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_BACK_OPERATE_TYPE_NONE` | **0** |
| `enum_BACK_OPERATE_TYPE_GET` | **1** |
| `enum_BACK_OPERATE_TYPE_SEND` | **2** |

### `Back$BACK_SERVICE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_BACK_SERVICE_TYPE_NONE` | **0** |
| `enum_BACK_SERVICE_TYPE_MAIN` | **1** |
| `enum_BACK_SERVICE_TYPE_WEATHER` | **2** |
| `enum_BACK_SERVICE_TYPE_AIR_PRESSURE` | **3** |
| `enum_BACK_SERVICE_TYPE_ELEVATION` | **4** |
| `enum_BACK_SERVICE_TYPE_EPHEMERIS` | **5** |
| `enum_BACK_SERVICE_TYPE_TIME` | **6** |
| `enum_BACK_SERVICE_TYPE_LOCATE_INFO` | **7** |

### `Back$BACK_SUB_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_BACK_SUB_OPERATE_TYPE_EPHEMERIS_PART_6H` | **1** |
| `enum_BACK_SUB_OPERATE_TYPE_DEFAULT` | **255** |

### `Back$GPS_TYPE`

| Constante | Valeur |
|---|---|
| `enum_GPS_TYPE_GPS` | **1** |
| `enum_GPS_TYPE_BD` | **2** |
| `enum_GPS_TYPE_GLONASS` | **3** |
| `enum_GPS_TYPE_GALILEO` | **4** |

### `Ble$BLE_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_BLE_OPERATE_TYPE_NONE` | **0** |
| `enum_BLE_OPERATE_TYPE_BOND_INFO` | **1** |
| `enum_BLE_OPERATE_TYPE_BOND_REQ` | **2** |
| `enum_BLE_OPERATE_TYPE_CONNECT_STATUS` | **3** |
| `enum_BLE_OPERATE_TYPE_UNBOND` | **4** |
| `enum_BLE_OPERATE_TYPE_WATCH_BOND_USER_GET` | **5** |
| `enum_BLE_OPERATE_TYPE_WATCH_BOND_USER_SET` | **7** |
| `enum_BLE_OPERATE_TYPE_WATCH_BOND_STATE_UPDATE` | **8** |
| `enum_BLE_OPERATE_TYPE_BOND_STATUS_GET` | **9** |
| `enum_BLE_OPERATE_TYPE_CHECK_MEMBER_ID` | **10** |

### `Common$SERVICE_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_SERVICE_OPERATE_TYPE_NONE` | **0** |
| `enum_SERVICE_OPERATE_TYPE_SET` | **1** |
| `enum_SERVICE_OPERATE_TYPE_GET` | **2** |
| `enum_SERVICE_OPERATE_TYPE_ADD` | **3** |
| `enum_SERVICE_OPERATE_TYPE_DEL` | **4** |

### `Common$service_type_index`

| Constante | Valeur |
|---|---|
| `enum_SERVICE_TYPE_INDEX_NONE` | **0** |
| `enum_SERVICE_TYPE_INDEX_INS` | **1** |
| `enum_SERVICE_TYPE_INDEX_MAP` | **2** |
| `enum_SERVICE_TYPE_INDEX_BACK` | **3** |
| `enum_SERVICE_TYPE_INDEX_FIRMWARE` | **4** |
| `enum_SERVICE_TYPE_INDEX_WIFI` | **5** |
| `enum_SERVICE_TYPE_INDEX_CYCLING_DATA` | **6** |
| `enum_SERVICE_TYPE_INDEX_ROUTE_PLAN` | **7** |
| `enum_SERVICE_TYPE_INDEX_REAL_TIME_TRACE` | **8** |
| `enum_SERVICE_TYPE_INDEX_USER_CONFIG` | **9** |
| `enum_SERVICE_TYPE_INDEX_BLE` | **10** |
| `enum_SERVICE_TYPE_INDEX_FACTORY` | **11** |
| `enum_SERVICE_TYPE_INDEX_CONFIG` | **12** |
| `enum_SERVICE_TYPE_INDEX_DEV_STATUS` | **13** |
| `enum_SERVICE_TYPE_INDEX_SENSOR` | **14** |
| `enum_SERVICE_TYPE_INDEX_TRAINING` | **15** |
| `enum_SERVICE_TYPE_INDEX_TEAM_INFO` | **16** |
| `enum_SERVICE_TYPE_INDEX_DEV_VER_INFO` | **17** |
| `enum_SERVICE_TYPE_INDEX_LANGUAGE` | **18** |
| `enum_SERVICE_TYPE_INDEX_LOG` | **19** |
| `enum_SERVICE_TYPE_INDEX_THEME` | **20** |
| `enum_SERVICE_TYPE_INDEX_FILE_OPERATION` | **21** |
| `enum_SERVICE_TYPE_INDEX_MAP_NEW` | **22** |
| `enum_SERVICE_TYPE_INDEX_ROUTE_BOOK` | **23** |
| `enum_SERVICE_TYPE_INDEX_STAGE` | **24** |
| `enum_SERVICE_TYPE_INDEX_TRAINING_PLAN` | **25** |
| `enum_SERVICE_TYPE_INDEX_ALG_GOMORE` | **26** |
| `enum_SERVICE_TYPE_INDEX_GROUP_RIDE` | **27** |
| `enum_SERVICE_TYPE_INDEX_CLOUD_SWITCH_DEV` | **28** |
| `enum_SERVICE_TYPE_INDEX_MUSIC_CTL` | **29** |
| `enum_SERVICE_TYPE_INDEX_WATCH_CONTROL` | **30** |
| `enum_SERVICE_TYPE_INDEX_WATCH_CONFIG` | **81** |
| `enum_SERVICE_TYPE_INDEX_WATCH_HEALTH` | **83** |
| `enum_SERVICE_TYPE_INDEX_WATCH_ALG_ACQUISITION` | **84** |
| `enum_SERVICE_TYPE_INDEX_WATCH_DIAL` | **85** |
| `enum_SERVICE_TYPE_INDEX_SPORT_PAGE_FILED` | **86** |
| `enum_SERVICE_TYPE_INDEX_SPORT_ABILITY` | **87** |

### `Config$ALARM_SELECT`

| Constante | Valeur |
|---|---|
| `ALARM_SELECT_INVALID` | **0** |
| `ALARM_SELECT_RIDE_TIME` | **1** |
| `ALARM_SELECT_DISTANCE` | **2** |
| `ALARM_SELECT_CALORIE` | **3** |

### `Config$ALARM_TYPE`

| Constante | Valeur |
|---|---|
| `ALARM_TYPE_INVALID` | **0** |
| `ALARM_TYPE_RIDE_TIME` | **1** |
| `ALARM_TYPE_RIDE_DISTANCE` | **2** |
| `ALARM_TYPE_HRM` | **3** |
| `ALARM_TYPE_CAD` | **4** |
| `ALARM_TYPE_PWR` | **5** |
| `ALARM_TYPE_CALORIE` | **6** |
| `ALARM_TYPE_SPEED` | **7** |
| `ALARM_TYPE_WATER` | **8** |
| `ALARM_TYPE_FOOD` | **9** |
| `ALARM_TYPE_CORE_TEMP` | **10** |

### `Config$AUTO_TYPE`

| Constante | Valeur |
|---|---|
| `enum_AUTO_TYPE_INVALID` | **0** |
| `enum_PAUSE` | **1** |
| `enum_RECORD_START` | **2** |
| `enum_POWER_OFF` | **3** |
| `enum_SLEEP` | **4** |
| `enum_HOME_PAGE_BACK` | **5** |
| `enum_SMART_SAVE` | **6** |
| `enum_POWER_SAVE` | **7** |
| `enum_PAGE_AUTO` | **8** |
| `enum_MOTION_CHECK` | **9** |

### `Config$CONFIG_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_CONFIG_OPERATE_TYPE_NONE` | **0** |
| `enum_CONFIG_OPERATE_TYPE_SET` | **1** |
| `enum_CONFIG_OPERATE_TYPE_GET` | **2** |
| `enum_CONFIG_OPERATE_TYPE_SEND` | **3** |
| `enum_CONFIG_OPERATE_TYPE_ADD` | **4** |
| `enum_CONFIG_OPERATE_TYPE_DEL` | **5** |
| `enum_CONFIG_OPERATE_TYPE_GET_MODULE_INFO` | **6** |
| `enum_CONFIG_OPERATE_TYPE_CTRL` | **7** |
| `enum_CONFIG_OPERATE_TYPE_SET_DEFAULT` | **8** |

### `Config$CONFIG_SERVICE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_CONFIG_SERVICE_TYPE_NONE` | **0** |
| `enum_CONFIG_SERVICE_TYPE_USER` | **1** |
| `enum_CONFIG_SERVICE_TYPE_PAGE` | **2** |
| `enum_CONFIG_SERVICE_TYPE_BIKE` | **3** |
| `enum_CONFIG_SERVICE_TYPE_UNIT` | **4** |
| `enum_CONFIG_SERVICE_TYPE_LANG` | **5** |
| `enum_CONFIG_SERVICE_TYPE_KEY` | **6** |
| `enum_CONFIG_SERVICE_TYPE_WHEEL` | **7** |
| `enum_CONFIG_SERVICE_TYPE_GPS` | **16** |
| `enum_CONFIG_SERVICE_TYPE_SOUND` | **17** |
| `enum_CONFIG_SERVICE_TYPE_POWER` | **18** |
| `enum_CONFIG_SERVICE_TYPE_DIS_COLOR` | **19** |
| `enum_CONFIG_SERVICE_TYPE_BK` | **20** |
| `enum_CONFIG_SERVICE_TYPE_TIME_SYS` | **21** |
| `enum_CONFIG_SERVICE_TYPE_ALARM` | **48** |
| `enum_CONFIG_SERVICE_TYPE_LAP` | **49** |
| `enum_CONFIG_SERVICE_TYPE_AUTO` | **50** |
| `enum_CONFIG_SERVICE_TYPE_MODE` | **51** |
| `enum_CONFIG_SERVICE_TYPE_ALTITUDE` | **52** |
| `enum_CONFIG_SERVICE_TYPE_DATA` | **53** |
| `enum_CONFIG_SERVICE_TYPE_MODE_TEMPLATE` | **54** |
| `enum_CONFIG_SERVICE_TYPE_PASSWORD` | **55** |
| `enum_CONFIG_SERVICE_TYPE_ACCIDENT` | **56** |

### `Config$DATA_TYPE`

| Constante | Valeur |
|---|---|
| `enum_DATA_TYPE_INVALID` | **0** |
| `enum_DATA_TYPE_PWR_WITH_ZERO` | **1** |
| `enum_DATA_TYPE_CAD_WITH_ZERO` | **2** |

### `Config$KEY_FUNCTION_TYPE`

| Constante | Valeur |
|---|---|
| `enum_KEY_FUNCTION_TYPE_INVALID` | **0** |
| `enum_RECORD_STATUS_MANUAL_PAUSE` | **1** |
| `enum_RECORD_STATUS_MANUAL_LAP` | **2** |
| `enum_RECORD_STATUS_FRONT_LIGHT` | **3** |
| `enum_RECORD_STATUS_TAIL_LIGHT` | **4** |

### `Config$KEY_TYPE`

| Constante | Valeur |
|---|---|
| `enum_KEY1` | **1** |
| `enum_KEY2` | **2** |
| `enum_KEY3` | **3** |
| `enum_KEY4` | **4** |
| `enum_KEY5` | **5** |
| `enum_KEY6` | **6** |

### `Config$LANGUAGE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_LANGUAGE_TYPE_INVALID` | **0** |
| `enum_LANGUAGE_TYPE_ENGLISH` | **1** |
| `enum_LANGUAGE_TYPE_SPANISH` | **2** |
| `enum_LANGUAGE_TYPE_FRENCH` | **3** |
| `enum_LANGUAGE_TYPE_GERMAN` | **4** |
| `enum_LANGUAGE_TYPE_JAPANESE` | **5** |
| `enum_LANGUAGE_TYPE_ITALIAN` | **6** |
| `enum_LANGUAGE_TYPE_PORTUGUESE` | **7** |
| `enum_LANGUAGE_TYPE_KOREAN` | **8** |
| `enum_LANGUAGE_TYPE_CHINESE` | **9** |
| `enum_LANGUAGE_TYPE_TAIWANESE` | **10** |
| `enum_LANGUAGE_TYPE_POLISH` | **11** |
| `enum_LANGUAGE_TYPE_CROATIAN` | **12** |
| `enum_LANGUAGE_TYPE_CZECH` | **13** |
| `enum_LANGUAGE_TYPE_DANISH` | **14** |
| `enum_LANGUAGE_TYPE_DUTCH` | **15** |
| `enum_LANGUAGE_TYPE_FINNISH` | **16** |
| `enum_LANGUAGE_TYPE_GREEK` | **17** |
| `enum_LANGUAGE_TYPE_HUNGARIAN` | **18** |
| `enum_LANGUAGE_TYPE_NORWEGIAN` | **19** |
| `enum_LANGUAGE_TYPE_SLOVAKIAN` | **20** |
| `enum_LANGUAGE_TYPE_SLOVENIAN` | **21** |
| `enum_LANGUAGE_TYPE_SWEDISH` | **22** |
| `enum_LANGUAGE_TYPE_RUSSIAN` | **23** |
| `enum_LANGUAGE_TYPE_TURKISH` | **24** |
| `enum_LANGUAGE_TYPE_LATVIAN` | **25** |
| `enum_LANGUAGE_TYPE_UKRAINIAN` | **26** |
| `enum_LANGUAGE_TYPE_ARABIC` | **27** |
| `enum_LANGUAGE_TYPE_FARSI` | **28** |
| `enum_LANGUAGE_TYPE_BULGARIAN` | **29** |
| `enum_LANGUAGE_TYPE_ROMANIAN` | **30** |
| `enum_LANGUAGE_TYPE_THAI` | **31** |
| `enum_LANGUAGE_TYPE_HEBREW` | **32** |
| `enum_LANGUAGE_TYPE_BRAZILIAN_PORTUGUESE` | **33** |
| `enum_LANGUAGE_TYPE_INDONESIAN` | **34** |
| `enum_LANGUAGE_TYPE_MALAYSIAN` | **35** |
| `enum_LANGUAGE_TYPE_VIETNAMESE` | **36** |
| `enum_LANGUAGE_TYPE_BURMESE` | **37** |
| `enum_LANGUAGE_TYPE_MONGOLIAN` | **38** |
| `enum_LANGUAGE_TYPE_ALL` | **100** |
| `enum_LANGUAGE_TYPE_CUSTOM` | **254** |

### `Config$LAP_TYPE`

| Constante | Valeur |
|---|---|
| `LAP_TYPE_INVALID` | **0** |
| `LAP_TYPE_LOCATION` | **1** |
| `LAP_TYPE_TIME` | **2** |
| `LAP_TYPE_DISTANCE` | **3** |

### `Config$LCD_TYPE`

| Constante | Valeur |
|---|---|
| `INVALID` | **0** |
| `PIXEL_LCD` | **1** |
| `SECTION_LCD` | **2** |

### `Config$PAGE_AUTO_STATUS`

| Constante | Valeur |
|---|---|
| `PAGE_AUTO_STATUS_OFF` | **0** |
| `PAGE_AUTO_STATUS_ON` | **1** |
| `PAGE_AUTO_STATUS_FAST` | **2** |
| `PAGE_AUTO_STATUS_SLOW` | **3** |
| `PAGE_AUTO_STATUS_MAIN` | **4** |

### `Config$PAGE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_PAGE_TYPE_INVALID` | **0** |
| `enum_PAGE_TYPE_DATA` | **1** |
| `enum_PAGE_TYPE_ELEVATION` | **2** |
| `enum_PAGE_TYPE_MAP` | **3** |
| `enum_PAGE_TYPE_AREA` | **4** |
| `enum_PAGE_TYPE_TRAINING_COURSE` | **5** |
| `enum_PAGE_TYPE_TRAINING_FEC` | **6** |
| `enum_PAGE_TYPE_COMPASS` | **7** |
| `enum_PAGE_TYPE_LAP` | **8** |
| `enum_PAGE_TYPE_ROADBOOK` | **9** |
| `enum_PAGE_TYPE_CLIMB` | **10** |
| `enum_PAGE_TYPE_AIPARTNER` | **11** |
| `enum_PAGE_TYPE_SEGMENT` | **12** |
| `enum_PAGE_TYPE_FITNESS` | **13** |
| `enum_PAGE_TYPE_CLIMB_MAP` | **14** |
| `enum_PAGE_TYPE_GROUP_RIDE_INFOR` | **15** |
| `enum_PAGE_TYPE_MUSIC` | **16** |
| `enum_PAGE_TYPE_CAMERA` | **17** |

### `Config$POWER_SAVE_STATUS`

| Constante | Valeur |
|---|---|
| `POWER_SAVE_STATUS_OFF` | **0** |
| `POWER_SAVE_STATUS_ON` | **1** |
| `POWER_SAVE_STATUS_SMART` | **2** |

### `Config$SECTION_HR_TYPE`

| Constante | Valeur |
|---|---|
| `SECTION_HR_TYPE_INVALID` | **0** |
| `SECTION_HR_TYPE_MAX` | **1** |
| `SECTION_HR_TYPE_LTHR` | **2** |
| `SECTION_HR_TYPE_RESERVE_HR` | **3** |

### `Config$SOUND_SCENE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_ALL_SCENE` | **1** |
| `enum_RECORDING_SCENE` | **2** |

### `Config$SOUND_TYPE`

| Constante | Valeur |
|---|---|
| `enum_SOUND_TYPE_INVALID` | **0** |
| `enum_SOUND_RECORD_START` | **1** |
| `enum_SOUND_RECORD_PAUSE` | **2** |
| `enum_SOUND_RECORD_SAVE` | **4** |
| `enum_SOUND_LAP` | **8** |
| `enum_SOUND_ALART` | **16** |
| `enum_SOUND_KEY` | **32** |
| `enum_SOUND_USB` | **64** |
| `enum_SOUND_GPS` | **128** |
| `enum_SOUND_SENSOR` | **256** |
| `enum_SOUND_CALL` | **512** |
| `enum_SOUND_SOCIAL` | **1024** |
| `enum_SOUND_BURGLAR_ALARM` | **2048** |
| `enum_SOUND_DEV_FIND` | **4096** |

### `Config$TIME_SYSTEM_TYPE`

| Constante | Valeur |
|---|---|
| `enum_TIME_SYSTEM_TYPE_12HOUR` | **1** |
| `enum_TIME_SYSTEM_TYPE_24HOUR` | **2** |

### `Config$UNIT_ITEM`

| Constante | Valeur |
|---|---|
| `enum_UNIT_ITEM_INVALID` | **0** |
| `enum_UNIT_ITEM_DISTANCE` | **1** |
| `enum_UNIT_ITEM_ELEVATION` | **2** |
| `enum_UNIT_ITEM_WEIGHT` | **3** |
| `enum_UNIT_ITEM_TEMPERATURE` | **4** |

### `Config$UNIT_TYPE`

| Constante | Valeur |
|---|---|
| `enum_UNIT_TYPE_INVALID` | **0** |
| `enum_UNIT_TYPE_METRIC` | **1** |
| `enum_UNIT_TYPE_INCH` | **2** |

### `CyclingData$CYCLING_DATA_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_CYCLING_DATA_OPERATE_TYPE_LIST_GET` | **1** |
| `enum_CYCLING_DATA_OPERATE_TYPE_LIST_SEND` | **2** |
| `enum_CYCLING_DATA_OPERATE_TYPE_FILE_GET` | **3** |
| `enum_CYCLING_DATA_OPERATE_TYPE_FILE_SEND` | **4** |
| `enum_CYCLING_DATA_OPERATE_TYPE_FILE_DEL` | **5** |
| `enum_CYCLING_DATA_OPERATE_TYPE_ALL_DEL` | **6** |
| `enum_CYCLING_DATA_OPERATE_TYPE_AUTO_UPLOAD` | **7** |
| `enum_CYCLING_DATA_OPERATE_TYPE_LIST_NUM_GET` | **8** |
| `enum_CYCLING_DATA_OPERATE_TYPE_ACTIVITY_UPLOAD_SERVER_SET` | **9** |

### `DevStatus$DEV_CYCLING_STATUS`

| Constante | Valeur |
|---|---|
| `DEV_CYCLING_STATUS_FREE` | **0** |
| `DEV_CYCLING_STATUS_DOING` | **1** |
| `DEV_CYCLING_STATUS_PAUSE` | **2** |

### `DevStatus$DEV_NAVI_STATUS`

| Constante | Valeur |
|---|---|
| `DEV_NAVI_STATUS_OFF` | **0** |
| `DEV_NAVI_STATUS_ON` | **1** |

### `DevStatus$DEV_STATUS_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_DEV_STATUS_OPERATE_TYPE_NONE` | **0** |
| `enum_DEV_STATUS_OPERATE_TYPE_GET` | **1** |
| `enum_DEV_STATUS_OPERATE_TYPE_SEND` | **2** |
| `enum_DEV_STATUS_OPERATE_TYPE_ADD_POSITION_POINT` | **3** |
| `enum_DEV_STATUS_OPERATE_TYPE_DELETE_POSITION_POINT` | **4** |
| `enum_DEV_STATUS_OPERATE_TYPE_MODIFY_POSITION_POINT` | **5** |

### `DevStatus$DEV_WIFI_STATUS`

| Constante | Valeur |
|---|---|
| `DEV_WIFI_STATUS_IDLE` | **1** |
| `DEV_WIFI_STATUS_MAP` | **2** |
| `DEV_WIFI_STATUS_FIRMWARE` | **3** |
| `DEV_WIFI_STATUS_UPLOAD` | **4** |
| `DEV_WIFI_STATUS_SET` | **5** |

### `DevVerInfo$OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_OPERATE_TYPE_NONE` | **0** |
| `enum_OPERATE_TYPE_SET` | **1** |
| `enum_OPERATE_TYPE_GET` | **2** |
| `enum_OPERATE_TYPE_SEND` | **3** |
| `enum_OPERATE_TYPE_ADD` | **4** |
| `enum_OPERATE_TYPE_DEL` | **5** |

### `DeviceInformation$DeviceCategoryType`

| Constante | Valeur |
|---|---|
| `DEVICE_CYCLE_COMPUTER` | **0** |
| `DEVICE_ACCESSORY` | **1** |
| `DEVICE_WATCH` | **2** |
| `DEVICE_WATCH_IGS` | **3** |

### `DeviceInformation$DeviceImage$ImageType`

| Constante | Valeur |
|---|---|
| `INVALID` | **0** |
| `BIG` | **1** |
| `SMALL` | **2** |
| `BACKGROUND_IN_PAGE_SETTING` | **3** |
| `DFU` | **4** |
| `UNBINDING_ANIMATION` | **5** |

### `DeviceInformation$FunctionType`

| Constante | Valeur |
|---|---|
| `DATA_MANAGEMENT_MODULE` | **0** |
| `DATA_MANAGEMENT_ACTIVITIES_FUNCTION` | **1** |
| `DATA_MANAGEMENT_ACTIVITIES_LIST_INFORMATION_FUNCTION` | **2** |
| `DATA_MANAGEMENT_ROUTES_FUNCTION` | **3** |
| `DATA_MANAGEMENT_WORKOUTS_FUNCTION` | **4** |
| `DATA_MANAGEMENT_SYNC_SETTING_FUNCTION` | **5** |
| `DEVICE_SETTINGS_MODULE` | **6** |
| `PROMPT_FOR_DELETION_WHEN_THE_DEVICE_ACTIVE_FILE_IS_FULL` | **7** |
| `SUPPORT_ACTIVITY_UPLOAD_SUCCESS_NOTIFY` | **8** |
| `NOTIFICATION_MODULE` | **31** |
| `NOTIFICATION_INCOMING_CALL_FUNCTION` | **32** |
| `NOTIFICATION_INCOMING_MESSAGE_FUNCTION` | **33** |
| `NOTIFICATION_APP_FUNCTION` | **34** |
| `NOTIFICATION_READ_SWITCH_STATUS` | **35** |
| `NOTIFICATION_SUPPORT_CUSTOM_APP_SWITCH` | **36** |
| `NOTIFICATION_SUPPORT_OTHER_SWITCH` | **37** |
| `NAVIGATION_MAP_MODULE` | **51** |
| `UNIT_MODULE` | **71** |
| `UNIT_METRIC_FUNCTION` | **72** |
| `UNIT_IMPERIAL_FUNCTION` | **73** |
| `UNIT_CUSTOMIZE_FUNCTION` | **74** |
| `CYCLING_COMPUTER_CONFIG_MODULE` | **91** |
| `KEY_FUNCTION_SET_SUB_MODULE` | **92** |
| `AUTO_FUNCTION_SET_SUB_MODULE` | **93** |
| `AUTO_PAUSE_FUNCTION` | **94** |
| `AUTO_RECORD_START_FUNCTION` | **95** |
| `AUTO_POWER_OFF_FUNCTION` | **96** |
| `AUTO_SLEEP_FUNCTION` | **97** |
| `AUTO_HOME_PAGE_BACK_FUNCTION` | **98** |
| `SMART_SAVE_FUNCTION` | **99** |
| `ALARM_SET_SUB_MODULE` | **100** |
| `ALARM_RIDE_TIME_FUNCTION` | **101** |
| `ALARM_RIDE_DISTANCE_FUNCTION` | **102** |
| `ALARM_HRM_FUNCTION` | **103** |
| `ALARM_CAD_FUNCTION` | **104** |
| `ALARM_PWR_FUNCTION` | **105** |
| `ALARM_CALORIE_FUNCTION` | **106** |
| `LAP_SET_SUB_MODULE` | **107** |
| `SOUND_MODULE` | **108** |
| `SOUND_KEY_FUNCTION` | **109** |
| `SOUND_BEEP_FUNCTION` | **110** |
| `UPLOAD_LOG_MODULE` | **111** |
| `AUTO_RECORD_START_SUPPORT_THRESHOLD` | **112** |
| `AUTO_PAUSE_SUPPORT_THRESHOLD` | **113** |
| `AUTO_FUNCTION_SET_SUB_MODULE_520` | **114** |
| `WEATHER_TEST_MODULE` | **141** |
| `ROUTES_MODULE` | **161** |
| `ROUTE_SUPPORT_DIFFERENCE_ALGORITHM` | **162** |
| `ROUTE_SUPPORT_ONLY_SINGLE_ROUTE` | **163** |
| `ROUTE_SUPPORT_AUXILIARY_POINT` | **164** |
| `ROUTE_SUPPORT_YAW_PLANNING` | **165** |
| `ROUTE_SUPPORT_ROUTE_PACKAGE` | **166** |
| `BROADCAST_MODULE` | **181** |
| `GROUP_TRACK_MODULE` | **182** |
| `SENSORS_MODULE` | **201** |
| `CRANK_LENGTH_PLUS` | **202** |
| `POWER_CALIBRATION` | **203** |
| `SUPPORT_SENSOR_SYNC` | **204** |
| `FIRMWARE_DETECTION_MODULE` | **221** |
| `WIFI_MODULE` | **251** |
| `PAGE_SETTING_MODULE` | **281** |
| `PAGE_SETTING_NAME_MAPPING` | **282** |
| `PAGE_COMPASS` | **283** |
| `TRAINING_MODULE` | **311** |
| `BIKE_SETTING_MODULE` | **341** |
| `PERSONAL_SETTINGS_MODULE` | **371** |
| `FONT_DOWNLOAD_MODULE` | **401** |
| `ANTI_THEFT_ALARM_MODULE` | **421** |
| `SEND_WEATHER_INFORMATION_MODULE` | **451** |
| `SEND_AGPS_MODULE` | **452** |
| `SEND_USER_INFORMATION_MODULE` | **453** |
| `SEND_OFFLINE_AGPS_MODULE` | **454** |
| `REMOVE_DEVICE_MODULE` | **501** |
| `MODEL_MANAGEMENT_MODULE` | **502** |
| `EDIT_MODEL_MANAGEMENT_MODULE` | **503** |
| `THEME_MANAGEMENT_MODULE` | **511** |
| `DISPLAY_SETTING_MODULE` | **521** |
| `ALTITUDE_CALIBRATION_MODULE` | **522** |
| `LOCATION_POINT_MANAGEMENT_MODULE` | **523** |
| `OTHER_SETTING_MODULE` | **531** |
| `CALCULATE_AVERAGE_CADENCE_FILTER_0_VALUE` | **532** |
| `CALCULATE_AVERAGE_POWER_FILTER_0_VALUE` | **533** |
| `MOTION_STATE_DETECTION` | **534** |
| `PRESS_TO_SWITCH_SPORT_MODE` | **535** |
| `AUTO_START_CUSTOM` | **541** |
| `AUTO_START_ALERT` | **542** |
| `AUTO_PAGE_SLOW` | **543** |
| `AUTO_PAGE_NORMAL` | **544** |
| `POWER_SAVING_MODEL` | **545** |
| `SMART_POWER_SAVING_FUNCTIONALITY` | **546** |
| `BLE_MAP_MODULE` | **547** |
| `ALARM_SPEED_FUNCTION` | **548** |
| `READ_SN_FUNCTION` | **549** |
| `HR_DEVICE` | **550** |
| `SPD_DEVICE` | **551** |
| `CAD_DEVICE` | **552** |
| `ADVANCED_HR_DEVICE` | **553** |
| `RADAR_DEVICE` | **554** |
| `SOUND_BEEP_MULTIPLE_CHOICE_FUNCTION` | **555** |
| `POWER_MANAGEMENT_MODULE` | **556** |
| `LIGHT_DEVICE` | **557** |
| `SUPPORT_STAGE` | **601** |
| `VITALITY_GOAL_MODULE` | **2000** |
| `HEALTH_DATA_DETECTION_MODULE` | **2010** |
| `HEALTH_REMIND_MODULE` | **2011** |
| `MY_HEALTH_DATA_MODULE` | **2020** |
| `DIAL_MODULE` | **2030** |
| `BLUETOOTH_CALL_MODULE` | **2060** |
| `SOS_CALL_MODULE` | **2070** |
| `PREFERENCES_MODULE` | **2080** |
| `WORLD_CLOCK` | **2081** |
| `ALARM_DRINK_WATER_FUNCTION` | **3001** |
| `ALARM_FOOD_FUNCTION` | **3002** |
| `GO_MORE_FUNCTION` | **3003** |
| `TRAINING_PLAN_FUNCTION` | **3004** |
| `ACCESSORY_READ_SN_FUNCTION` | **3005** |
| `ONE_KEY_NAVIGATION_FUNCTION` | **3006** |
| `READ_DEVICE_BATTERY_FUNCTION` | **3007** |
| `DEVICE_LOG` | **3008** |
| `PREFABRICATED_COURSES` | **3009** |
| `DEVICE_AVAILABLE_TIME` | **3010** |
| `DEVICE_CURRENT_MODE` | **3011** |
| `SUPPORT_LIGHT_MODE_QUICK_CARD` | **3012** |
| `CLOUD_DEVICE_SYNC` | **3013** |
| `SUPPORT_MUSIC_CONTROL` | **3014** |
| `ALARM_CORE_TEMPERATURE_FUNCTION` | **3015** |
| `DEVICE_SETTING_SPORT_MODE_SETTING` | **3016** |
| `DEVICE_FUNCTION_DRIVING_STATE_NOTIFY` | **3017** |
| `DEVICE_SETTING_MENU_MANAGEMENT` | **3018** |
| `SUPPORT_RUNNING_TRAINING` | **3019** |
| `SUPPORT_FILE_TRANSFER_METHOD` | **3020** |
| `APP_SETTING_FIND_DEVICE` | **3021** |
| `SUPPORT_READ_MODE_CUSTOM_TEMPLATE` | **3022** |
| `SUPPORT_CYCLE_COMPUTER_WATCH_INTERCONNECTION` | **3023** |
| `SUPPORT_TIME_FORMAT_SETTING` | **3024** |
| `SUPPORT_PASSWORD_SETTING` | **3025** |
| `SUPPORT_WIFI_FIRMWARE_UPGRADE` | **3026** |
| `SUPPORT_ACCIDENT_DETECTION` | **3027** |
| `SUPPORT_FIRMWARE_AUTO_DOWNLOAD_SWITCH` | **3028** |

### `DeviceInformation$MapManual$ManualType`

| Constante | Valeur |
|---|---|
| `INVALID` | **0** |
| `UNBIND` | **1** |
| `CONNECT_HELP` | **2** |

### `DeviceInformation$PagingInformation$Function`

| Constante | Valeur |
|---|---|
| `INVALID` | **0** |
| `ACTIVITIES` | **1** |
| `ROUTES` | **2** |
| `WORKOUTS` | **3** |

### `DeviceInformation$PairMode`

| Constante | Valeur |
|---|---|
| `NONE` | **0** |
| `JUST_WORKS` | **1** |
| `PASSKEY_ENTRY` | **2** |
| `NUMERIC_COMPARISON` | **3** |

### `EmojiLight$EMOJI_ATTRIBUTE_TYPE`

| Constante | Valeur |
|---|---|
| `EAT_SPD` | **0** |
| `EAT_CAD` | **1** |
| `EAT_HR` | **2** |
| `EAT_PWR` | **3** |
| `EAT_DIS` | **4** |
| `EAT_TIME` | **5** |

### `EmojiLight$EMOJI_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `EOT_DOWNLOAD_START` | **1** |
| `EOT_DOWNLOAD_ING` | **2** |
| `EOT_DOWNLOAD_SAVE` | **3** |
| `EOT_DOWNLOAD_PREVIEW` | **4** |

### `EmojiLight$EMOJI_SERVICE_TYPE`

| Constante | Valeur |
|---|---|
| `EST_BASE_MSG` | **1** |
| `EST_EMOJI_DOWNLOAD` | **2** |
| `EST_EMOJI_DELETE` | **3** |
| `EST_EMOJI_MODIFY` | **4** |
| `EST_EMOJI_DETAIL` | **5** |
| `EST_EMOJI_ABBR` | **6** |
| `EST_EMOJI_SWITCH` | **7** |
| `EST_EMOJI_CURRENT_USE` | **8** |

### `EmojiLight$SINGLE_EMOJI_MODE`

| Constante | Valeur |
|---|---|
| `SEM_INVALID` | **0** |
| `SEM_MODE_0` | **1** |
| `SEM_MODE_1` | **2** |
| `SEM_MODE_2` | **3** |
| `SEM_MODE_3` | **4** |
| `SEM_MODE_4` | **5** |
| `SEM_MODE_5` | **6** |
| `SEM_MODE_6` | **7** |

### `Factory$ANT_DEV_TYPE`

| Constante | Valeur |
|---|---|
| `enumInvalid_dev_type` | **0** |
| `enumHrm_dev_type` | **1** |
| `enumCbsc_dev_type` | **2** |
| `enumBpwr_dev_type` | **3** |
| `enumCad_dev_type` | **5** |
| `enumSpd_dev_type` | **6** |
| `enumShft_dev_type` | **7** |
| `enumDi2_dev_type` | **8** |
| `enumFe_dev_type` | **9** |
| `enumMax_dev_type` | **10** |

### `Factory$CONTROL_CMD_TYPE`

| Constante | Valeur |
|---|---|
| `enum_CMD_INVALID` | **0** |
| `enum_CMD_ENTER_CHECK` | **1** |
| `enum_CMD_LOCK` | **2** |
| `enum_CMD_FORMAT` | **16** |
| `enum_CMD_LFORMAT` | **17** |
| `enum_CMD_PARA_RESET` | **18** |
| `enum_CMD_FACTORY_RESET` | **19** |
| `enum_CMD_TEMPERATURE_LOG` | **32** |
| `enum_CMD_VOLTAGE_LOG` | **33** |
| `enum_CMD_ANT_LOG` | **34** |

### `Factory$FACTORY_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_FACTORY_OPERATE_TYPE_NONE` | **0** |
| `enum_FACTORY_OPERATE_TYPE_SN_GET` | **1** |
| `enum_FACTORY_OPERATE_TYPE_SN_SEND` | **2** |
| `enum_FACTORY_OPERATE_TYPE_SN_SET` | **3** |
| `enum_FACTORY_OPERATE_TYPE_SENSOR_GET` | **4** |
| `enum_FACTORY_OPERATE_TYPE_MEMORY_GET` | **5** |
| `enum_FACTORY_OPERATE_TYPE_BATTARY_GET` | **6** |
| `enum_FACTORY_OPERATE_TYPE_SIM_FIT_SET` | **7** |
| `enum_FACTORY_OPERATE_TYPE_GPS_COORDINATE_SET` | **8** |
| `enum_FACTORY_OPERATE_TYPE_SUN_TIME_SET` | **9** |
| `enum_FACTORY_OPERATE_TYPE_SUN_TIME_GET` | **10** |
| `enum_FACTORY_OPERATE_TYPE_POWER_SAVE_TIME_SET` | **11** |
| `enum_FACTORY_OPERATE_TYPE_RTC_SET` | **12** |
| `enum_FACTORY_OPERATE_TYPE_RTC_GET` | **13** |
| `enum_FACTORY_OPERATE_TYPE_FILTER_SET` | **14** |
| `enum_FACTORY_OPERATE_TYPE_FILTER_GET` | **15** |
| `enum_FACTORY_OPERATE_TYPE_GPS_CONTROL_CMD_SET` | **16** |
| `enum_FACTORY_OPERATE_TYPE_GPS_CONTROL_CMD_GET` | **17** |
| `enum_FACTORY_OPERATE_TYPE_GPS_GNSS_SET` | **18** |
| `enum_FACTORY_OPERATE_TYPE_GPS_GNSS_GET` | **19** |
| `enum_FACTORY_OPERATE_TYPE_GPS_DYNAMIC_SET` | **20** |
| `enum_FACTORY_OPERATE_TYPE_GPS_DYNAMIC_GET` | **21** |
| `enum_FACTORY_OPERATE_TYPE_GPS_CMD_SET` | **22** |
| `enum_FACTORY_OPERATE_TYPE_CONTROL_SET` | **23** |
| `enum_FACTORY_OPERATE_TYPE_CONTROL_DATA_SET` | **24** |
| `enum_FACTORY_OPERATE_TYPE_ALL_GET` | **254** |

### `Factory$FACTORY_SENSOR_TYPE`

| Constante | Valeur |
|---|---|
| `enum_SENSOR_INVALID` | **0** |
| `enum_GPS` | **1** |
| `enum_RTC` | **2** |
| `enum_AIR` | **3** |
| `enum_TEM` | **4** |
| `enum_ACC` | **5** |
| `enum_ANT` | **6** |
| `enum_KEY` | **7** |

### `Factory$FILTER_TYPE`

| Constante | Valeur |
|---|---|
| `enum_FILTER_INVALID` | **0** |
| `enum_FILTER_SMART_SAVE` | **1** |
| `enum_FILTER_SPD` | **2** |
| `enum_FILTER_CAD` | **3** |
| `enum_FILTER_HRM` | **4** |
| `enum_FILTER_GPS_ICON` | **5** |
| `enum_FLTER_ANT_ICON` | **6** |

### `Factory$GNSS_TYPE`

| Constante | Valeur |
|---|---|
| `enum_GNSS_INVALID` | **0** |
| `enum_GNSS_GPS` | **1** |
| `enum_GNSS_BD` | **2** |
| `enum_GNSS__GLONASS` | **4** |
| `enum_GNSS__QZSS` | **8** |
| `enum_GNSS_SBAS` | **16** |
| `enum_GNSS_GALILEO` | **32** |
| `enum_GNSS_IMES` | **64** |

### `Factory$GPS_CONTROL_CMD_TYPE`

| Constante | Valeur |
|---|---|
| `enum_GPS_CMD_INVALID` | **0** |
| `enum_GPS_CMD_POWER` | **1** |
| `enum_GPS_CMD_COLD_START` | **2** |
| `enum_GPS_CMD_POWER_SAVE` | **3** |
| `enum_GPS_CMD_GNSS` | **4** |

### `Factory$GPS_DYNAMIC_TYPE`

| Constante | Valeur |
|---|---|
| `enum_GPS_DYNAMIC_INVALID` | **0** |
| `euum_PORTABLE` | **1** |
| `enum_STATIONARY` | **2** |
| `enum_PEDESTRIAN` | **3** |
| `enum_AUTOMOTIVE` | **4** |
| `enum_SEA` | **5** |
| `enum_1G` | **6** |
| `enum_2G` | **7** |
| `enum_4G` | **8** |
| `enum_WRIST` | **9** |
| `enum_BIKE` | **10** |

### `Firmware$FIRMWARE_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_FIRMWARE_OPERATE_TYPE_NONE` | **0** |
| `enum_FIRMWARE_OPERATE_TYPE_GET_VERSION` | **1** |
| `enum_FIRMWARE_OPERATE_TYPE_SEND_VERSION` | **2** |
| `enum_FIRMWARE_OPERATE_TYPE_MCU_UPDATE` | **3** |
| `enum_FIRMWARE_OPERATE_TYPE_PROGRESS` | **4** |
| `enum_FIRMWARE_OPERATE_TYPE_BLE_UPDATE` | **5** |
| `enum_FIRMWARE_OPERATE_TYPE_GET_AUTO_DOWNLOAD_STATUS` | **6** |
| `enum_FIRMWARE_OPERATE_TYPE_SET_AUTO_DOWNLOAD_STATUS` | **7** |

### `GeneralFileOperation$file_operation_type`

| Constante | Valeur |
|---|---|
| `enum_FILE_TYPE_GENERAL` | **0** |
| `enum_FILE_TYPE_TRAINING` | **1** |
| `enum_FILE_TYPE_ROUTE_PLAN` | **2** |
| `enum_FILE_TYPE_MAP` | **3** |
| `enum_FILE_TYPE_THEME` | **4** |
| `enum_FILE_TYPE_FIRMWARE` | **5** |
| `enum_FILE_TYPE_LANGUAGE` | **6** |
| `enum_FILE_TYPE_AGPS` | **7** |
| `enum_FILE_TYPE_ROUTE_BOOK` | **8** |
| `enum_FILE_TYPE_STAGE` | **9** |
| `enum_FILE_TYPE_POWERON_IMG` | **10** |
| `enum_FILE_TYPE_SCHEDULE` | **11** |
| `enum_FILE_TYPE_THEME_BACKGOUND` | **12** |
| `enum_FILE_TYPE_GROUP_RIDE_USER_HEAD_PORTRAIT` | **13** |
| `enum_FILE_TYPE_CLOUD_SWITCH_DEV` | **14** |
| `enum_FILE_TYPE_GROUP_RIDE_ROUTE_BOOK` | **15** |
| `enum_FILE_TYPE_WATCH_DIAL` | **16** |
| `enum_FILE_TYPE_YAW_ANT_RENAVI_BOOK` | **17** |
| `enum_FILE_TYPE_WATCH_PHOTO_DIAL` | **18** |

### `GroupRide$exit_reason`

| Constante | Valeur |
|---|---|
| `enum_INVALID_REASON` | **0** |
| `enum_VOLUNTARY` | **1** |
| `enum_TIMEOUT` | **2** |
| `enum_DISSOLVE` | **3** |
| `enum_KICKED_OUT` | **4** |

### `GroupRide$group_ride_msg_type`

| Constante | Valeur |
|---|---|
| `enum_INVALID_TYPE` | **0** |
| `enum_ONLINE_STATUS_COMFIRM_TYPE` | **1** |
| `enum_MEMBER_PERSONAL_INFOR` | **2** |
| `enum_MEMBER_GROUP_RIDE_INFOR` | **3** |
| `enum_MEMBER_DANGROUS_INFOR` | **4** |
| `enum_GROUP_RIDE_CTRL_ENTER` | **5** |
| `enum_GROUP_RIDE_CTRL_EXIT` | **6** |
| `enum_GROUP_RIDE_CTRL_START` | **7** |
| `enum_GROUP_RIDE_CTRL_FILE_START` | **8** |
| `enum_GROUP_RIDE_CTRL_FILE_END` | **9** |
| `enum_NOTICE_MSG` | **10** |

### `GroupRide$group_ride_notice_cmd`

| Constante | Valeur |
|---|---|
| `enum_INVALID_CMD` | **0** |
| `enum_ONLINE_STATUS_COMFIRM` | **1** |
| `enum_EMERGENCY_CALLING` | **2** |
| `enum_DANGEROUS_POINT_MARK` | **3** |
| `enum_GROUP_RIDE_ENTER` | **4** |
| `enum_GROUP_RIDE_EXIT` | **5** |
| `enum_GROUP_RIDE_REJECT` | **6** |
| `enum_ROUTE_UPDTAE_ACCEPT` | **7** |

### `GroupRide$member_identity_infor`

| Constante | Valeur |
|---|---|
| `enum_GROUP_RIDE_LEADER` | **1** |
| `enum_GROUP_RIDE_VICE_LEADER` | **2** |
| `enum_GROUP_RIDE_MEMBER` | **3** |

### `GroupRide$member_status`

| Constante | Valeur |
|---|---|
| `enum_GROUP_RIDE_INVALID_STATUS` | **0** |
| `enum_EXIT` | **1** |
| `enum_ONLINE` | **2** |
| `enum_OFFLINE` | **3** |

### `Ins$ANCS_CATAGORY_ID`

| Constante | Valeur |
|---|---|
| `OTHER` | **0** |
| `INCOMING_CALL` | **1** |
| `MISSED_CALL` | **2** |
| `VOICE_MAIL` | **3** |
| `SOCIAL` | **4** |
| `ID_SCHEDULE` | **5** |
| `ID_EMAIL` | **6** |
| `NEWS` | **7** |
| `HEALTH_AND_FITNESS` | **8** |
| `BUSINESS_AND_FINANCE` | **9** |
| `LOCATION` | **10** |
| `ENTERTAINMENT` | **11** |

### `Ins$INS_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_INS_OPERATE_TYPE_NONE` | **0** |
| `enum_INS_OPERATE_TYPE_CTRL` | **1** |
| `enum_INS_OPERATE_TYPE_INCOMING_CALL` | **2** |
| `enum_INS_OPERATE_TYPE_ANSWER_CALL` | **3** |
| `enum_INS_OPERATE_TYPE_REJECT_CALL` | **4** |
| `enum_INS_OPERATE_TYPE_CHECK_CALL` | **5** |
| `enum_INS_OPERATE_TYPE_INCOMING_NOTE` | **6** |
| `enum_INS_OPERATE_TYPE_CHECK_NOTE` | **7** |
| `enum_INS_OPERATE_TYPE_GET_SWITCH_STATUS` | **8** |
| `enum_INS_OPERATE_TYPE_SET_APP_LIST` | **9** |
| `enum_INS_OPERATE_TYPE_DEVICE_REJECT_CALL` | **10** |
| `enum_INS_OPERATE_TYPE_DEVICE_MUTE_CALL` | **11** |
| `enum_INS_OPERATE_TYPE_FIND_START` | **12** |
| `enum_INS_OPERATE_TYPE_FIND_STOP` | **13** |

### `Ins$INS_SERVICE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_INS_SERVICE_TYPE_NONE` | **0** |
| `enum_INS_SERVICE_TYPE_MAIN` | **1** |
| `enum_INS_SERVICE_TYPE_CALL` | **2** |
| `enum_INS_SERVICE_TYPE_NOTE` | **3** |
| `enum_INS_SERVICE_TYPE_FIND_PHONE` | **4** |
| `enum_INS_SERVICE_TYPE_FIND_WATCH` | **5** |

### `LanguagePack$LANGUAGE_PACK_FONT_TYPE`

| Constante | Valeur |
|---|---|
| `enum_DianDian` | **1** |

### `LanguagePack$LANGUAGE_PACK_SUB_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_LANG_SUB_OPERATE_TYPE_INVALID` | **0** |
| `enum_LANG_SUB_OPERATE_TYPE_SET_DOWNLOAD_URL` | **1** |
| `enum_LANG_SUB_OPERATE_TYPE_GET_MODULE_INFO` | **16** |
| `enum_LANG_SUB_OPERATE_TYPE_GET_LIST` | **17** |
| `enum_LANG_SUB_OPERATE_TYPE_ADD_PACK` | **32** |
| `enum_LANG_SUB_OPERATE_TYPE_DEL_PACK` | **48** |

### `Log$LOG_SUB_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_LOG_INVALID` | **0** |
| `enum_LOG_NUMBER_GET` | **16** |
| `enum_LOG_GET` | **17** |
| `enum_DEBUG_LOG_PACK_REQUEST` | **18** |
| `enum_DEBUG_LOG_PACK_COMPLETE` | **19** |
| `enum_LOG_UPLOAD_TO_SERVER` | **20** |

### `Map$MAP_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_MAP_OPERATE_TYPE_NONE` | **0** |
| `enum_MAP_OPERATE_TYPE_LIST_GET` | **1** |
| `enum_MAP_OPERATE_TYPE_LIST_SEND` | **2** |
| `enum_MAP_OPERATE_TYPE_ASSIGN_UPDATE` | **3** |
| `enum_MAP_OPERATE_TYPE_ALL_UPDATE` | **4** |
| `enum_MAP_OPERATE_TYPE_DOWNLOAD` | **5** |
| `enum_MAP_OPERATE_TYPE_SUCCESS` | **6** |
| `enum_MAP_OPERATE_YPTE_CANCEL_DOWNLOAD` | **7** |
| `enum_MAP_OPERATE_TYPE_PROGRESS_GET` | **8** |
| `enum_MAP_OPERATE_TYPE_PROGRESS_UPLOAD` | **9** |
| `enum_MAP_OPERATE_TYPE_ASSIGN_DEL` | **10** |
| `enum_MAP_OPERATE_TYPE_ALL_DEL` | **11** |
| `enum_MAP_CONFIG_CMD` | **12** |

### `Media$MEDIA_STATUS`

| Constante | Valeur |
|---|---|
| `INVALID_STATUS` | **0** |
| `NO_ACCESS_STATUS` | **1** |

### `Media$PLAYER_STATE`

| Constante | Valeur |
|---|---|
| `PAUSED` | **0** |
| `PLAYING` | **1** |
| `REWINDING` | **2** |
| `FORWARDING` | **3** |

### `Media$QUENE_PLAY_MODE`

| Constante | Valeur |
|---|---|
| `ONE_REPEAT` | **0** |
| `ALL_REPEAT` | **1** |
| `SHUFFLE` | **2** |

### `Media$REMOTE_CMD`

| Constante | Valeur |
|---|---|
| `PLAY` | **0** |
| `PAUSE` | **1** |
| `TOGGLE_PLAY_PAUSE` | **2** |
| `NEXT_TRACK` | **3** |
| `PREVIOUS_TRACK` | **4** |
| `VOLUME_UP` | **5** |
| `VOLUME_DOWN` | **6** |

### `PeripheralCommon$PERIPHERAL_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `POT_SET` | **1** |
| `POT_GET` | **2** |
| `POT_ADD` | **3** |
| `POT_DEL` | **4** |
| `POT_CON` | **5** |
| `POT_REQUEST` | **6** |
| `POT_RESPONSE` | **7** |

### `PeripheralCommon$PERIPHERAL_SERVICE_TYPE`

| Constante | Valeur |
|---|---|
| `PST_INFO` | **101** |
| `PST_CONFIG` | **102** |
| `PST_HR` | **103** |
| `PST_RADAR` | **104** |
| `PST_LIGHT` | **105** |
| `PST_BLE_LIGHT` | **106** |
| `PST_BLE_LIGHT_INBIKE` | **107** |
| `PST_MUTUAL_TRANS` | **108** |
| `PST_EMOJI_LIGHT` | **109** |
| `PST_FIRMWARE` | **121** |
| `PST_FACTORY` | **131** |
| `PST_OEM` | **132** |

### `PeripheralConfig$PERIPHERAL_CONFIG_SERVICE`

| Constante | Valeur |
|---|---|
| `PCS_SHUTDOWN` | **4** |
| `PCS_SLEEP` | **5** |
| `PCS_LIGHT_MODE` | **6** |
| `PCS_DATA_BROADCAST` | **7** |
| `PCS_ALL_CONFIG` | **21** |
| `PCS_ALL_CONFIG_RESET` | **22** |

### `PeripheralConfig$enum_PERIPHERAL_CONFIG_LIGHT_MODE`

| Constante | Valeur |
|---|---|
| `DEVICE_SCENE_OFF` | **4** |
| `DEVICE_SCENE_DEFAULT` | **5** |
| `DEVICE_SCENE_TEAM` | **6** |
| `DEVICE_SCENE_GRADIENT` | **7** |
| `DEVICE_SCENE_NIGHT` | **8** |
| `DEVICE_SCENE_DAYLIGHT` | **9** |

### `PeripheralFactory$PERIPHERAL_FACTORY_RADAR_TEST_OPERATE`

| Constante | Valeur |
|---|---|
| `FAS_NSPECIFIED_RADAR` | **0** |
| `FAS_RADAR_TEST_OPEN` | **1** |
| `FAS_RADAR_TEST_CLOSE` | **2** |

### `PeripheralFactory$PERIPHERAL_FACTORY_SERVICE`

| Constante | Valeur |
|---|---|
| `FAS_UNSPECIFIED` | **0** |
| `FAS_SN` | **1** |
| `FAS_DEVICE_INFO` | **2** |
| `FAS_DEVICE_OPERATE` | **3** |
| `FAS_DEVICE_CONFIG` | **4** |
| `FAS_BSP_MEMORY` | **21** |
| `FAS_BSP_RTC` | **22** |
| `FAS_BSP_BATTARY` | **23** |
| `FAS_BSP_TEMPERATURE` | **24** |
| `FAS_BSP_ACC` | **25** |
| `FAS_BSP_LSR` | **26** |
| `FAS_BSP_RGB` | **27** |
| `FAS_LED_TEST_PERI` | **28** |
| `FAS_THERMISTOR_VOL` | **29** |
| `FAS_ALL_FACTORY` | **41** |
| `FAS_LED_TEST_BUTTON` | **42** |
| `FAS_MOTOR_TEST_BUTTON` | **43** |
| `FAS_ENTER_FACTORY` | **44** |
| `FAS_RADAR_TEST` | **45** |
| `FAS_FACTORY_ARG` | **46** |
| `FAS_ANT_ID` | **47** |
| `FAS_CURRENT_TEST` | **48** |
| `FAS_VOID_WELDING_TEST` | **49** |
| `FAS_MAX_LUMEN_TEST` | **50** |
| `FAS_SLEEP_ENTER_TEST` | **51** |
| `FAS_RADAR_CALIB_FCAL` | **52** |
| `FAS_RADAR_CALIB_FDECT` | **53** |
| `FAS_CAPACITANCE` | **54** |
| `FAS_RESTORE_FACTORY_AND_ENTER_SHIP_MODE` | **55** |
| `FAS_CALIBRATE_AND_INIT` | **56** |
| `FAS_AIR_SELF_LEARN` | **57** |
| `FAS_SIMULATE_TEST` | **58** |
| `FAS_REBOOT_DEVICE` | **59** |
| `FAS_PPG_START_TEST` | **60** |
| `FAS_PPG_TEST_RESULT` | **61** |
| `FAS_ENTER_SLEEP` | **62** |

### `PeripheralFactory$PPG_TEST_STATE`

| Constante | Valeur |
|---|---|
| `PPG_STATE_IDLE` | **0** |
| `PPG_STATE_PASS` | **1** |
| `PPG_STATE_FAIL` | **2** |
| `PPG_STATE_RUNNING` | **3** |

### `PeripheralFactory$PPG_TEST_TYPE`

| Constante | Valeur |
|---|---|
| `PPG_TEST_TYPE_PPG_ALL` | **1** |
| `PPG_TEST_TYPE_PPG_LPLCTR` | **2** |

### `PeripheralFirmware$PERIPHERAL_FIRMWARE_OPERATE`

| Constante | Valeur |
|---|---|
| `PFO_MCU_UPDATE_START` | **1** |
| `PFO_MCU_UPDATE_PROCESS` | **2** |
| `PFO_MCU_UPDATE_END` | **3** |
| `PFO_MCU_UPDATE_ERROR` | **4** |

### `PeripheralFirmware$PERIPHERAL_FIRMWARE_SERVICE`

| Constante | Valeur |
|---|---|
| `PFS_ENTER_DFU` | **1** |
| `PFS_MCU_UPDATE` | **2** |
| `PFS_FW_STATUS` | **3** |

### `PeripheralHr$PERIPHERAL_HR_SERVICE`

| Constante | Valeur |
|---|---|
| `PHS_NSPECIFIED` | **0** |
| `PHS_HRM_WARN` | **6** |
| `PHS_HRM_ZONE` | **11** |
| `PHS_SPORT_MODE` | **16** |

### `PeripheralHr$PERIPHERAL_HR_SPORT_MODE_TYPE`

| Constante | Valeur |
|---|---|
| `PHSM_DEFAULT` | **1** |
| `PHSM_RUN` | **2** |
| `PHSM_BIKE` | **3** |
| `PHSM_FITNESS` | **4** |

### `PeripheralHr$PERIPHERAL_HR_WARN_TYPE`

| Constante | Valeur |
|---|---|
| `PHW_UNSPECIFIED` | **0** |
| `PHW_CUSTOM` | **1** |
| `PHW_ZONE` | **2** |

### `PeripheralInfo$PERIPHERAL_INFO_MODEL_TYPE`

| Constante | Valeur |
|---|---|
| `PIM_HR70` | **1** |

### `PeripheralInfo$PERIPHERAL_INFO_SERVICE`

| Constante | Valeur |
|---|---|
| `PIS_UNSPECIFIED` | **0** |
| `PIS_MODEL` | **1** |
| `PIS_NAME` | **2** |
| `PIS_VERSION` | **3** |
| `PIS_ID` | **11** |
| `PIS_POWER` | **16** |
| `PIS_TEMPERATURE` | **17** |
| `PIS_MEMORY` | **18** |
| `PIS_ALL_INFO` | **31** |

### `PeripheralLight$AUTO_CONFIG_TYPE`

| Constante | Valeur |
|---|---|
| `enum_AUTO_CONFIG_INVALID` | **0** |
| `enum_AUTO_CONFIG_FOLLOW` | **1** |
| `enum_AUTO_CONFIG_SELF` | **2** |
| `enum_AUTO_CONFIG_OFF` | **3** |

### `PeripheralLight$FOLLOW_MODE_FLAG`

| Constante | Valeur |
|---|---|
| `enum_MODE_FLAG_INVALID` | **0** |
| `enum_MODE_FLAG_TRUE` | **1** |
| `enum_MODE_FLAG_FALSE` | **2** |

### `PeripheralLight$PERIPHERAL_LIGHT_CONFIG_SUP`

| Constante | Valeur |
|---|---|
| `PLCS_INVALID` | **0** |
| `PLCS_ROUTE` | **1** |
| `PLCS_RIDE_SYNC` | **2** |
| `PLCS_BRAKE_LIGHT` | **3** |
| `PLCS_SYNC_LIGHT` | **4** |
| `PLCS_SYNC_SLEEP` | **5** |
| `PLCS_SYNC_OFF` | **6** |
| `PLCS_TEAM_RIDE` | **7** |
| `PLCS_RADAR` | **8** |
| `PLCS_END` | **31** |

### `PeripheralLight$PERIPHERAL_LIGHT_CUSTOME_MODE`

| Constante | Valeur |
|---|---|
| `PLCM_GRADIENT` | **1** |
| `PLCM_REGULAR_BLINK` | **2** |
| `PLCM_ALWAYS` | **3** |

### `PeripheralLight$PERIPHERAL_LIGHT_MODE`

| Constante | Valeur |
|---|---|
| `PLM_HIGH_ALWAYS` | **1** |
| `PLM_MID_ALWAYS` | **2** |
| `PLM_LOW_ALWAYS` | **3** |
| `PLM_HIGH_BLINK` | **4** |
| `PLM_LOW_BLINK` | **5** |
| `PLM_GRADIENT` | **6** |
| `PLM_CUSTOMIZE` | **7** |
| `PLM_LIGHT_OFF` | **20** |

### `PeripheralLight$PERIPHERAL_LIGHT_SERVICE`

| Constante | Valeur |
|---|---|
| `PLS_NSPECIFIED` | **0** |
| `PLS_LIGHT_TYPE` | **1** |
| `PLS_LIGHT_MODE_SUP` | **6** |
| `PLS_LIGHT_CURRENT` | **7** |
| `PLS_LIGHT_CUSTOME` | **8** |
| `PLS_CUSTOME_SET` | **9** |
| `PLS_LIGHT_AUTO_CONFIG` | **14** |
| `PLS_SLEEP_FOLLOW` | **15** |
| `PLS_AUTOLIGHT_FOLLOW` | **16** |
| `PLS_SYC_OFF` | **17** |
| `PLS_REMAINING_TIME` | **18** |
| `PLS_LIGHT_CFG_SUP` | **19** |

### `PeripheralLight$PERIPHERAL_LIGHT_TYPE`

| Constante | Valeur |
|---|---|
| `PLT_INVALID` | **0** |
| `PLT_TAIL_LIGHT` | **1** |
| `PLT_FRONT_LIGHT` | **2** |
| `PLT_HEAD_LIGHT` | **3** |
| `PLT_LEFT_LIGHT` | **4** |
| `PLT_RIGHT_LIGHT` | **5** |
| `PLT_TIRE_LIGHT` | **6** |
| `PLT_PACK_LIGHT` | **7** |
| `PLT_PEDAL_LIGHT` | **8** |
| `PLT_FRAME_LIGHT` | **9** |
| `PLT_SPOKE_LIGHT` | **10** |
| `PLT_RADAR_LIGHT` | **11** |

### `PeripheralLightApp$BLE_LIGHT_CONFIG_SUP`

| Constante | Valeur |
|---|---|
| `BLCS_ROUTE` | **0** |
| `BLCS_RIDE_SYNC` | **1** |
| `BLCS_BRAKE_LIGHT` | **2** |
| `BLCS_AUTO_LIGHT` | **3** |
| `BLCS_AUTO_SLEEP` | **4** |
| `BLCS_SYNC_OFF` | **5** |
| `BLCS_TEAM_RIDE` | **6** |
| `BLCS_RADAR` | **7** |
| `BLCS_AUTO_START` | **8** |
| `BLCS_LUMEN_VARY` | **9** |
| `BLCS_ANGEL_VARY` | **10** |
| `BLCS_HL_BEAM` | **11** |
| `BLCS_AUTO_TURN` | **12** |
| `BLCS_AUTO_LOW` | **13** |
| `BLCS_SLP_VARY` | **14** |
| `BLCS_AUTO_LOWBAT` | **15** |
| `BLCS_INTELL_SAVING` | **16** |
| `BLCS_KNOCK_TRANS` | **17** |
| `BLCS_AUTO_LOOP` | **18** |
| `BLCS_STOP_FLASH` | **19** |
| `BLCS_AD_WARN` | **20** |
| `BLCS_RADAR_WARN` | **21** |

### `PeripheralLightApp$BLE_LIGHT_CUSTOM_SUBTYPE`

| Constante | Valeur |
|---|---|
| `BLCM_FLICKER` | **1** |
| `BLCS_BREATH` | **2** |

### `PeripheralLightApp$BLE_LIGHT_MODE`

| Constante | Valeur |
|---|---|
| `BLM_LIGHT_OFF` | **0** |
| `BLM_HIGH_ALWAYS` | **1** |
| `BLM_MID_ALWAYS` | **2** |
| `BLM_LOW_ALWAYS` | **3** |
| `BLM_HIGH_BLINK` | **4** |
| `BLM_LOW_BLINK` | **5** |
| `BLM_GRADIENT` | **6** |
| `BLM_HBEAM_HSTEADY` | **7** |
| `BLM_HBEAM_MSTEADY` | **8** |
| `BLM_HBEAM_LSTEADY` | **9** |
| `BLM_LBEAM_HSTEADY` | **10** |
| `BLM_LBEAM_MSTEADY` | **11** |
| `BLM_LBEAM_LSTEADY` | **12** |
| `BLM_ROTATION` | **13** |
| `BLM_LEFT_TURN` | **14** |
| `BLM_RIGHT_TURN` | **15** |
| `BLM_SUPERHIGH` | **16** |
| `BLM_SOS_WARNING` | **17** |
| `BLM_COMET_FLASH` | **18** |
| `BLM_WATERFALL_FLASH` | **19** |
| `BLM_PINWHEEL` | **20** |
| `BLM_SPECIAL_1` | **32** |
| `BLM_SPECIAL_2` | **33** |
| `BLM_SPECIAL_3` | **34** |
| `BLM_SPECIAL_4` | **35** |
| `BLM_SPECIAL_5` | **36** |
| `BLM_SPECIAL_6` | **37** |
| `BLM_SPECIAL_7` | **38** |
| `BLM_SPECIAL_8` | **39** |
| `BLM_SPECIAL_9` | **40** |
| `BLM_SPECIAL_10` | **41** |
| `BLM_CUSTOMIZE_1` | **64** |
| `BLM_CUSTOMIZE_2` | **65** |
| `BLM_CUSTOMIZE_3` | **66** |
| `BLM_CUSTOMIZE_4` | **67** |
| `BLM_CUSTOMIZE_5` | **68** |
| `BLM_CUSTOMIZE_6` | **69** |
| `BLM_CUSTOMIZE_7` | **70** |
| `BLM_CUSTOMIZE_8` | **71** |
| `BLM_CUSTOMIZE_9` | **72** |
| `BLM_CUSTOMIZE_10` | **73** |
| `BLM_CUSTOMIZE_11` | **74** |
| `BLM_CUSTOMIZE_12` | **75** |

### `PeripheralLightApp$BLE_LIGHT_MODE_TYPE`

| Constante | Valeur |
|---|---|
| `BLMT_TYPE_CUSTOM` | **1** |

### `PeripheralLightApp$BLE_LIGHT_OPERATE`

| Constante | Valeur |
|---|---|
| `BLO_OPERATE_GET` | **1** |
| `BLO_OPERATE_NTC` | **2** |
| `BLO_OPERATE_ENABLE` | **3** |
| `BLO_OPERATE_DISABLE` | **4** |

### `PeripheralLightApp$BLE_LIGHT_SERVICE`

| Constante | Valeur |
|---|---|
| `BLS_LIGHT_CFG` | **0** |
| `BLS_MODE_SUP` | **1** |
| `BLS_MODE_CUR` | **2** |
| `BLS_CUSTOME_MODE` | **3** |
| `BLS_SMT_CONFIG` | **4** |
| `BLS_LEFT_TIME` | **5** |
| `BLS_BAT_PCT` | **6** |
| `BLS_MODE_ENABLE` | **7** |
| `BLS_CONFIG_RESPECTIVE` | **8** |
| `BLS_RIDE_CFG` | **9** |

### `PeripheralLightApp$BLE_LIGHT_TYPE`

| Constante | Valeur |
|---|---|
| `BLT_TAIL_LIGHT` | **0** |
| `BLT_FRONT_LIGHT` | **1** |
| `BLT_HEAD_LIGHT` | **2** |
| `BLT_LEFT_LIGHT` | **3** |
| `BLT_RIGHT_LIGHT` | **4** |
| `BLT_TIRE_LIGHT` | **5** |
| `BLT_PACK_LIGHT` | **6** |
| `BLT_PEDAL_LIGHT` | **7** |
| `BLT_FRAME_LIGHT` | **8** |
| `BLT_SPOKE_LIGHT` | **9** |
| `BLT_RADAR_LIGHT` | **10** |
| `BLT_TURN_LIGHT` | **11** |
| `BLT_FLASH_LIGHT` | **12** |

### `PeripheralLightApp$BLT_SMT_CFG_STATUS`

| Constante | Valeur |
|---|---|
| `BSCS_CFG_OFF` | **0** |
| `BSCS_CFG_ON` | **1** |
| `BSCS_CFG_FOL` | **2** |

### `PeripheralLightApp$BRAKE_LIGHT_INTENSITY`

| Constante | Valeur |
|---|---|
| `LOW` | **0** |
| `MEDIUM` | **1** |
| `HIGH` | **2** |

### `PeripheralOem$PERIPHERAL_OEM_SERVICE`

| Constante | Valeur |
|---|---|
| `POS_BLE_INFO` | **1** |
| `POS_DEVICE_INFO` | **2** |
| `POS_MANUFACTURER_INFO` | **3** |
| `POS_ALL_OEM` | **11** |

### `PeripheralRadar$PERIPHERAL_RADAR_OPERATE`

| Constante | Valeur |
|---|---|
| `PHO_NSPECIFIED_RADAR` | **0** |
| `PHO_RADAR_TARGET` | **1** |
| `PHO_ACC_SAMPLE` | **2** |

### `RealTimeTrace$REAL_TIME_TRACE_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_REAL_TIME_TRACE_OPERATE_TYPE_GET` | **1** |
| `enum_REAL_TIME_TRACE_OPERATE_TYPE_FIT` | **2** |
| `enum_REAL_TIME_TRACE_OPERATE_TYPE_FINISH` | **3** |
| `enum_REAL_TIME_TRACE_OPERATE_TYPE_END` | **4** |

### `RouteBook$ROUTE_BOOK_FILE_STATUS`

| Constante | Valeur |
|---|---|
| `enum_ROUTE_BOOK_FILE_INVALID_STATUS` | **0** |
| `enum_ROUTE_BOOK_FILE_USED_STATUS` | **1** |
| `enum_ROUTE_BOOK_FILE_UNUSED_STATUS` | **2** |

### `RouteBook$ROUTE_BOOK_SUB_OP_TYPE`

| Constante | Valeur |
|---|---|
| `enum_ROUTE_BOOK_GET_SUB_OP_TYPE_NONE` | **0** |
| `enum_ROUTE_BOOK_GET_SUB_OP_TYPE_LIST_NUM_GET` | **1** |
| `enum_ROUTE_BOOK_GET_SUB_OP_TYPE_LIST_GET` | **2** |
| `enum_ROUTE_BOOK_SET_SUB_OP_TYPE_USE` | **17** |
| `enum_ROUTE_BOOK_SET_SUB_OP_TYPE_RENAME` | **18** |

### `RoutePlan$ROUTE_PLAN_FILE_STATUS`

| Constante | Valeur |
|---|---|
| `enum_INVALID_STATUS` | **0** |
| `enum_USED_STATUS` | **1** |
| `enum_UNUSED_STATUS` | **2** |

### `RoutePlan$ROUTE_PLAN_FILE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_ROUTE_PLAN_FILE_TYPE_INVALID` | **0** |
| `enum_ROUTE_PLAN_FILE_TYPE_CNX` | **1** |
| `enum_ROUTE_PLAN_FILE_TYPE_GPX` | **2** |
| `enum_ROUTE_PLAN_FILE_TYPE_FIT` | **3** |
| `enum_ROUTE_PLAN_FILE_TYPE_TCX` | **4** |
| `enum_ROUTE_PLAN_FILE_TYPE_XML` | **5** |

### `RoutePlan$ROUTE_PLAN_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_ROUTE_PLAN_OPERATE_TYPE_NONE` | **0** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_LIST_GET` | **1** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_LIST_SEND` | **2** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_FILE_DEL` | **3** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_FILE_SEND` | **4** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_FILE_USE` | **5** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_FILES_DEL` | **6** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_LIST_NUM_GET` | **7** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_RENAME` | **8** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_TURN_PROMPT` | **9** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_NOTIFY_TRAJECTORY_DEVIATION` | **10** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_ROUTE_POINT_GET` | **11** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_ROUTE_REROUTE_STATUS` | **12** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_REQUEST_WHETHER_SUPPORT_FUNCTION` | **13** |
| `enum_ROUTE_PLAN_OPERATE_TYPE_SUPPORT_FUNCTION_ENABLE_STATUS` | **14** |
| `ENUM_ROUTE_PLAN_OPERATE_TYPE_PACKET_FILE_SEND_END` | **15** |

### `RoutePlan$ROUTE_TURN_PROMPT`

| Constante | Valeur |
|---|---|
| `enumNAVI_TRUN_LEFT_ROUND` | **0** |
| `enumNAVI_TURN_LEFT_SHARPLY` | **1** |
| `enumNAVI_TURN_LEFT_NORMALLY` | **2** |
| `enumNAVI_TURN_LEFT_FRONT` | **3** |
| `enumNAVI_TURN_RIGHT_FRONT` | **4** |
| `enumNAVI_TURN_RIGHT_NORMALLY` | **5** |
| `enumNAVI_TURN_RIGHT_SHARPLY` | **6** |
| `enumNAVI_TRUN_RIGHT_ROUND` | **7** |
| `enumNAVI_TRUN_LEFT_ROUND_AT_ONCE` | **8** |
| `enumNAVI_TURN_LEFT_AT_ONCE` | **9** |
| `enumNAVI_TURN_LEFT_NORMALLY_AT_ONCE` | **10** |
| `enumNAVI_TURN_LEFT_FRONT_AT_ONCE` | **11** |
| `enumNAVI_TURN_RIGHT_FRONT_AT_ONCE` | **12** |
| `enumNAVI_TURN_RIGHT_NORMALLY_AT_ONCE` | **13** |
| `enumNAVI_TURN_RIGHT_AT_ONCE` | **14** |
| `enumNAVI_TRUN_RIGHT_ROUND_AT_ONCE` | **15** |
| `enumNAVI_TRUN_WINDING` | **16** |
| `enumNAVI_START_NAVIGATION` | **17** |
| `enumNAVI_YAW` | **18** |
| `enumNAVI_YAW_ANT_RENAVI` | **19** |
| `enumNAVI_YAW_RECOVERY` | **20** |
| `enumNAVI_NAVIGATION_END` | **21** |

### `RoutePlan$route_reroute_status`

| Constante | Valeur |
|---|---|
| `enum_ROUTE_REROUTE_ERROR_PLANNING_FAILED` | **1** |

### `Sensor$DI2_BUTTON_OP_TYPE`

| Constante | Valeur |
|---|---|
| `enum_DI2_BUTTON_OP_TYPE_LONG` | **0** |
| `enum_DI2_BUTTON_OP_TYPE_SINGLE` | **1** |
| `enum_DI2_BUTTON_OP_TYPE_DOUBLE` | **2** |

### `Sensor$DI2_CHN_NUM`

| Constante | Valeur |
|---|---|
| `enum_DI2_CHN_NUM_0` | **0** |
| `enum_DI2_CHN_NUM_1` | **1** |
| `enum_DI2_CHN_NUM_2` | **2** |
| `enum_DI2_CHN_NUM_3` | **3** |

### `Sensor$DI2_FUNC_TYPE`

| Constante | Valeur |
|---|---|
| `enum_DI2_FUNC_INVALID` | **0** |
| `enum_DI2_FUNC_PAGE_UP` | **1** |
| `enum_DI2_FUNC_PAGE_DOWN` | **2** |
| `enum_DI2_FUNC_LAP` | **3** |
| `enum_DI2_FUNC_START_PAUSE` | **4** |
| `enum_DI2_FUNC_UNDEFINE` | **15** |

### `Sensor$SENSOR_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_SENSOR_OPERATE_TYPE_NONE` | **0** |
| `enum_SENSOR_OPERATE_TYPE_GET` | **1** |
| `enum_SENSOR_OPERATE_TYPE_SET` | **2** |
| `enum_SENSOR_OPERATE_TYPE_DEL` | **3** |
| `enum_SENSOR_OPERATE_TYPE_CONNECT` | **4** |
| `enum_SENSOR_OPERATE_TYPE_SEND` | **5** |
| `enum_SENSOR_OPERATE_TYPE_EXIT` | **6** |
| `enum_SENSOR_OPERATE_TYPE_POW_CALIB` | **7** |
| `enum_SENSOR_OPERATE_TYPE_SYNC` | **8** |
| `enum_SENSOR_OPERATE_TYPE_QUERY` | **9** |

### `Sensor$SENSOR_RADIO_TYPE`

| Constante | Valeur |
|---|---|
| `enum_SENSOR_RADIO_TYPE_BLE` | **1** |
| `enum_SENSOR_RADIO_TYPE_ANT` | **2** |

### `Sensor$SENSOR_STATUS_TYPE`

| Constante | Valeur |
|---|---|
| `enum_SENSOR_STATUS_TYPE_CONNECTED` | **1** |
| `enum_SENSOR_STATUS_TYPE_NO_SAVED` | **2** |

### `Sensor$SENSOR_TYPE`

| Constante | Valeur |
|---|---|
| `enum_SENSOR_TYPE_INVALID` | **0** |
| `enum_SENSOR_TYPE_HRM` | **1** |
| `enum_SENSOR_TYPE_CBSC` | **2** |
| `enum_SENSOR_TYPE_PEDAL_BPWR` | **3** |
| `enum_SENSOR_TYPE_OTHER_BPWR` | **4** |
| `enum_SENSOR_TYPE_CAD` | **5** |
| `enum_SENSOR_TYPE_SPD` | **6** |
| `enum_SENSOR_TYPE_SHFT` | **7** |
| `enum_SENSOR_TYPE_DI2` | **8** |
| `enum_SENSOR_TYPE_FEC` | **9** |
| `enum_SENSOR_TYPE_LEV` | **10** |
| `enum_SENSOR_TYPE_RD` | **11** |
| `enum_SENSOR_TYPE_RADAR` | **12** |
| `enum_SENSOR_TYPE_LIGHT` | **13** |
| `enum_SENSOR_TYPE_CORE_TEMP` | **14** |
| `enum_SENSOR_TYPE_CAMERA` | **15** |
| `enum_SENSOR_TYPE_WATCH` | **16** |
| `enum_SENSOR_TYPE_TVBS` | **17** |
| `enum_SENSOR_TYPE_AERO` | **18** |
| `enum_SENSOR_TYPE_BODY` | **19** |

### `SportAbility$SPORT_ABILITY_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_SPORT_ABILITY_OPERATE_TYPE_DATA_SYNC` | **1** |
| `enum_SPORT_ABILITY_OPERATE_TYPE_FILE_PACKAGED_REQUEST` | **2** |
| `enum_SPORT_ABILITY_OPERATE_TYPE_FILE_PACKAGED_COMPLETE` | **3** |
| `enum_SPORT_ABILITY_OPERATE_TYPE_FILE_GET` | **4** |

### `SportPageField$SPORT_PAGE_FIELD_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_SPORT_PAGE_FIELD_OPERATE_TYPE_GET` | **1** |

### `Stage$STAGE_DATA_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_STAGE_DATA_OPERATE_TYPE_LIST_NUM_GET` | **1** |
| `enum_STAGE_DATA_OPERATE_TYPE_LIST_GET` | **2** |
| `enum_STAGE_DATA_OPERATE_TYPE_FILE_DEL` | **3** |
| `enum_STAGE_DATA_OPERATE_TYPE_FILE_SYNC_START` | **4** |
| `enum_STAGE_DATA_OPERATE_TYPE_FILE_SYNC_END` | **5** |

### `TeamInfo$MEMBER_STATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_MEMBER_STATE_TYPE_INVALID` | **0** |
| `enum_MEMBER_STATE_TYPE_NORMAL` | **1** |
| `enum_MEMBER_STATE_TYPE_ABNORMAL` | **2** |
| `enum_MEMBER_STATE_TYPE_OFFLINE` | **3** |
| `enum_MEMBER_STATE_TYPE_JOIN` | **4** |
| `enum_MEMBER_STATE_TYPE_QUIT` | **5** |

### `TeamInfo$TEAM_INFO_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_TEAM_INFO_OPERATE_TYPE_NONE` | **0** |
| `enum_TEAM_INFO_OPERATE_TYPE_SET` | **1** |

### `Theme$enum_bg_type`

| Constante | Valeur |
|---|---|
| `BG_TYPE_INVALID` | **0** |
| `BG_TYPE_POWERON` | **1** |
| `BG_TYPE_THEME1` | **2** |
| `BG_TYPE_THEME2` | **3** |
| `BG_TYPE_THEME3` | **4** |

### `Theme$enum_operate`

| Constante | Valeur |
|---|---|
| `THEME_OP_INVALID` | **0** |
| `THEME_OP_LIST_GET` | **1** |
| `THEME_OP_SET` | **2** |
| `THEME_OP_USE` | **3** |
| `THEME_OP_DEFAULT_BG` | **4** |
| `THEME_OP_GET_BG` | **5** |

### `Theme$enum_theme_dark_mode`

| Constante | Valeur |
|---|---|
| `THEME_DARK_MODE_DAY` | **0** |
| `THEME_DARK_MODE_NIGHT` | **1** |
| `THEME_DARK_MODE_AUTO` | **2** |

### `Theme$enum_theme_func_key`

| Constante | Valeur |
|---|---|
| `THEME_FUNC_KEY_INVALID` | **0** |
| `THEME_FUNC_KEY_RIDE` | **1** |
| `THEME_FUNC_KEY_WORKOUT` | **2** |
| `THEME_FUNC_KEY_NAVI` | **3** |
| `THEME_FUNC_KEY_THEME` | **4** |
| `THEME_FUNC_KEY_HISTORY` | **5** |
| `THEME_FUNC_KEY_SET` | **6** |
| `THEME_FUNC_KEY_ROADBOOK` | **7** |
| `THEME_FUNC_KEY_INS` | **8** |
| `THEME_FUNC_KEY_SAFETY_TRACK` | **9** |
| `THEME_FUNC_KEY_PM` | **10** |
| `THEME_FUNC_KEY_SENSOR` | **11** |
| `THEME_FUNC_KEY_SYSTEM` | **12** |
| `THEME_FUNC_KEY_WEATHER` | **13** |
| `THEME_FUNC_KEY_STAGE` | **14** |
| `THEME_FUNC_KEY_RECORD` | **15** |
| `THEME_FUNC_KEY_FITNESS_LEVEL` | **16** |
| `THEME_FUNC_KEY_TRAINNING_STATUS` | **17** |
| `THEME_FUNC_KEY_RECOVERY_STATUS` | **18** |
| `THEME_FUNC_KEY_GROUP_RIDE` | **19** |
| `THEME_FUNC_KEY_OFFLINE_PLAN` | **20** |
| `THEME_FUNC_KEY_TRACK_NAVI` | **21** |
| `THEME_FUNC_KEY_VIRTUAL_CYCLING` | **22** |

### `Theme$enum_theme_height`

| Constante | Valeur |
|---|---|
| `THEME_KEY_HEIGHT_1` | **1** |
| `THEME_KEY_HEIGHT_2` | **2** |
| `THEME_KEY_HEIGHT_3` | **3** |
| `THEME_KEY_HEIGHT_4` | **4** |

### `Theme$enum_theme_status`

| Constante | Valeur |
|---|---|
| `THEME_STATUS_UNUSED` | **0** |
| `THEME_STATUS_USED` | **1** |

### `Theme$enum_theme_uitype`

| Constante | Valeur |
|---|---|
| `THEME_UITYPE_SIX_GRID` | **0** |
| `THEME_UITYPE_ROLLER` | **1** |
| `THEME_UITYPE_SPIN_ROLLER` | **2** |

### `Theme$enum_theme_width`

| Constante | Valeur |
|---|---|
| `THEME_KEY_WIDTH_1` | **1** |
| `THEME_KEY_WIDTH_2` | **2** |
| `THEME_KEY_WIDTH_3` | **3** |
| `THEME_KEY_WIDTH_4` | **4** |

### `TrainPlan$TRAINING_PLAN_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_TRAINING_PLAN_OPERATE_TYPE_NONE` | **0** |
| `enum_TRAINING_PLAN_OPERATE_TYPE_GET_SCHEDULE_NUM` | **1** |
| `enum_TRAINING_PLAN_OPERATE_TYPE_GET_SCHEDULE_FILE` | **2** |
| `enum_TRAINING_PLAN_OPERATE_TYPE_SYNC_TRAINING_FILE_START` | **3** |
| `enum_TRAINING_PLAN_OPERATE_TYPE_SYNC_TRAINING_FILE_END` | **4** |
| `enum_TRAINING_PLAN_OPERATE_TYPE_UPDATE_SCHEDULE_STATE_INFO` | **5** |

### `Training$TRAINING_FILE_STATUS`

| Constante | Valeur |
|---|---|
| `enum_TRAINING_INVALID_STATUS` | **0** |
| `enum_TRAINING_USED_STATUS` | **1** |
| `enum_TRAINING_UNUSED_STATUS` | **2** |

### `Training$TRAINING_FILE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_TRAINING_FILE_TYPE_INVALIDE` | **0** |
| `enum_TRAINING_FILE_TYPE_JSON` | **1** |
| `enum_TRAINING_FILE_TYPE_XML` | **2** |
| `enum_TRAINING_FILE_TYPE_FIT` | **3** |
| `enum_TRAINING_FILE_TYPE_CSV` | **4** |
| `enum_TRAINING_FILE_TYPE_GPX` | **5** |
| `enum_TRAINING_FILE_TYPE_GZ` | **6** |
| `enum_TRAINING_FILE_TYPE_HRM` | **7** |
| `enum_TRAINING_FILE_TYPE_HST` | **8** |
| `enum_TRAINING_FILE_TYPE_PWPB` | **9** |
| `enum_TRAINING_FILE_TYPE_PWX` | **10** |
| `enum_TRAINING_FILE_TYPE_SDF` | **11** |
| `enum_TRAINING_FILE_TYPE_SRM` | **12** |
| `enum_TRAINING_FILE_TYPE_TCX` | **13** |
| `enum_TRAINING_FILE_TYPE_TXT` | **14** |
| `enum_TRAINING_FILE_TYPE_WKO` | **15** |
| `enum_TRAINING_FILE_TYPE_XLSX` | **16** |
| `enum_TRAINING_FILE_TYPE_CUSTOM` | **254** |

### `Training$TRAINING_OBJECT`

| Constante | Valeur |
|---|---|
| `enum_TRAINING_OBJECT_INVALID` | **0** |
| `enum_TRAINING_OBJECT_TIME` | **1** |
| `enum_TRAINING_OBJECT_DISTANCE` | **2** |
| `enum_TRAINING_OBJECT_SPD` | **3** |
| `enum_TRAINING_OBJECT_CALORIE` | **4** |
| `enum_TRAINING_OBJECT_CLIMB` | **5** |
| `enum_TRAINING_OBJECT_PWR` | **6** |
| `enum_TRAINING_OBJECT_PWR_ZONE` | **7** |
| `enum_TRAINING_OBJECT_HRM` | **8** |
| `enum_TRAINING_OBJECT_HRM_ZONE` | **9** |
| `enum_TRAINING_OBJECT_CUSTOM` | **254** |

### `Training$TRAINING_SUB_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_TRAINING_SUB_OPERATE_TYPE_INAVLIDE` | **0** |
| `enum_TRAINING_SUB_OPERATE_TYPE_SET_USE` | **1** |
| `enum_TRAINING_SUB_OPERATE_TYPE_SET_NAME` | **2** |
| `enum_TRAINING_SUB_OPERATE_TYPE_SET_REMIND` | **3** |
| `enum_TRAINING_SUB_OPERATE_TYPE_GET_MODULE_INFO` | **17** |
| `enum_TRAINING_SUB_OPERATE_TYPE_GET_LIST` | **18** |
| `enum_TRAINING_SUB_OPERATE_TYPE_GET_LIST_NUM` | **19** |
| `enum_TRAINING_SUB_OPERATE_TYPE_ADD_FILE` | **33** |
| `enum_TRAINING_SUB_OPERATE_TYPE_DEL_FILE` | **49** |

### `Training$TRAINING_TYPE`

| Constante | Valeur |
|---|---|
| `enum_TRAINING_TYPE_INVALID` | **0** |
| `enum_TRAINING_TYPE_WORKOUT` | **1** |
| `enum_TRAINING_TYPE_SEGMENT` | **2** |
| `enum_TRAINING_TYPE_INDOOR` | **3** |
| `enum_TRAINING_TYPE_CUSTOM` | **254** |

### `UserConfig$USER_CONFIG_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_USER_CONFIG_OPERATE_TYPE_NONE` | **0** |
| `enum_USER_CONFIG_OPERATE_TYPE_SET` | **1** |
| `enum_USER_CONFIG_OPERATE_TYPE_GET` | **2** |

### `WatchConfig$WATCH_ALARM_SELECT`

| Constante | Valeur |
|---|---|
| `WATCH_ALARM_SELECT_INVALID` | **0** |
| `WATCH_ALARM_SELECT_TIME` | **1** |
| `WATCH_ALARM_SELECT_CALORIE` | **3** |

### `WatchConfig$WATCH_ALARM_TYPE`

| Constante | Valeur |
|---|---|
| `WATCH_ALARM_TYPE_INVALID` | **0** |
| `WATCH_ALARM_TYPE_TIME` | **1** |
| `WATCH_ALARM_TYPE_DISTANCE` | **2** |
| `WATCH_ALARM_TYPE_HRM` | **3** |
| `WATCH_ALARM_TYPE_CAD` | **4** |
| `WATCH_ALARM_TYPE_PWR` | **5** |
| `WATCH_ALARM_TYPE_CONSUME` | **6** |
| `WATCH_ALARM_TYPE_SPEED` | **7** |
| `WATCH_ALARM_TYPE_PACE` | **10** |
| `WATCH_ALARM_TYPE_STEP_RATE` | **11** |
| `WATCH_ALARM_TYPE_STEP_NUM` | **12** |
| `WATCH_ALARM_TYPE_FEED` | **13** |

### `WatchConfig$WATCH_AUTO_STOP_MODE`

| Constante | Valeur |
|---|---|
| `WATCH_AUTO_STOP_MODE_INVALID` | **0** |
| `WATCH_AUTO_STOP_MODE_MOTIONLESS` | **1** |
| `WATCH_AUTO_STOP_MODE_SPEED` | **2** |
| `WATCH_AUTO_STOP_MODE_PACE` | **3** |

### `WatchConfig$WATCH_AUTO_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_AUTO_TYPE_INVALID` | **0** |
| `enum_WATCH_PAUSE` | **1** |
| `enum_WATCH_PAGE_AUTO` | **8** |

### `WatchConfig$WATCH_CONFIG_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_CONFIG_OPERATE_TYPE_NONE` | **0** |
| `enum_WATCH_CONFIG_OPERATE_TYPE_SET` | **1** |
| `enum_WATCH_CONFIG_OPERATE_TYPE_GET` | **2** |
| `enum_WATCH_CONFIG_OPERATE_TYPE_SEND` | **3** |
| `enum_WATCH_CONFIG_OPERATE_TYPE_ADD` | **4** |
| `enum_WATCH_CONFIG_OPERATE_TYPE_DEL` | **5** |
| `enum_WATCH_CONFIG_OPERATE_TYPE_GET_MODULE_INFO` | **6** |
| `enum_WATCH_CONFIG_OPERATE_TYPE_CTRL` | **7** |
| `enum_WATCH_CONFIG_OPERATE_TYPE_SET_DEFAULT` | **8** |

### `WatchConfig$WATCH_CONFIG_SERVICE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_CONFIG_SERVICE_TYPE_NONE` | **0** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_USER` | **1** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_PAGE` | **2** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_UNIT` | **4** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_LANG` | **5** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_KEY` | **6** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_MENUS` | **8** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_GPS` | **16** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_SOUND` | **17** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_POWER` | **18** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_DIS_COLOR` | **19** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_BK` | **20** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_TIME_SYS` | **21** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_ALARM` | **48** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_LAP` | **49** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_AUTO` | **50** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_MODE` | **51** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_ALTITUDE` | **52** |
| `enum_WATCH_CONFIG_SERVICE_TYPE_DATA` | **53** |

### `WatchConfig$WATCH_LANGUAGE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_LANGUAGE_TYPE_INVALID` | **0** |
| `enum_WATCH_LANGUAGE_TYPE_ENGLISH` | **1** |
| `enum_WATCH_LANGUAGE_TYPE_SPANISH` | **2** |
| `enum_WATCH_LANGUAGE_TYPE_FRENCH` | **3** |
| `enum_WATCH_LANGUAGE_TYPE_GERMAN` | **4** |
| `enum_WATCH_LANGUAGE_TYPE_JAPANESE` | **5** |
| `enum_WATCH_LANGUAGE_TYPE_ITALIAN` | **6** |
| `enum_WATCH_LANGUAGE_TYPE_PORTUGUESE` | **7** |
| `enum_WATCH_LANGUAGE_TYPE_KOREAN` | **8** |
| `enum_WATCH_LANGUAGE_TYPE_CHINESE` | **9** |
| `enum_WATCH_LANGUAGE_TYPE_TAIWANESE` | **10** |
| `enum_WATCH_LANGUAGE_TYPE_POLISH` | **11** |
| `enum_WATCH_LANGUAGE_TYPE_CROATIAN` | **12** |
| `enum_WATCH_LANGUAGE_TYPE_CZECH` | **13** |
| `enum_WATCH_LANGUAGE_TYPE_DANISH` | **14** |
| `enum_WATCH_LANGUAGE_TYPE_DUTCH` | **15** |
| `enum_WATCH_LANGUAGE_TYPE_FINNISH` | **16** |
| `enum_WATCH_LANGUAGE_TYPE_GREEK` | **17** |
| `enum_WATCH_LANGUAGE_TYPE_HUNGARIAN` | **18** |
| `enum_WATCH_LANGUAGE_TYPE_NORWEGIAN` | **19** |
| `enum_WATCH_LANGUAGE_TYPE_SLOVAKIAN` | **20** |
| `enum_WATCH_LANGUAGE_TYPE_SLOVENIAN` | **21** |
| `enum_WATCH_LANGUAGE_TYPE_SWEDISH` | **22** |
| `enum_WATCH_LANGUAGE_TYPE_RUSSIAN` | **23** |
| `enum_WATCH_LANGUAGE_TYPE_TURKISH` | **24** |
| `enum_WATCH_LANGUAGE_TYPE_LATVIAN` | **25** |
| `enum_WATCH_LANGUAGE_TYPE_UKRAINIAN` | **26** |
| `enum_WATCH_LANGUAGE_TYPE_ARABIC` | **27** |
| `enum_WATCH_LANGUAGE_TYPE_FARSI` | **28** |
| `enum_WATCH_LANGUAGE_TYPE_BULGARIAN` | **29** |
| `enum_WATCH_LANGUAGE_TYPE_ROMANIAN` | **30** |
| `enum_WATCH_LANGUAGE_TYPE_THAI` | **31** |
| `enum_WATCH_LANGUAGE_TYPE_HEBREW` | **32** |
| `enum_WATCH_LANGUAGE_TYPE_BRAZILIAN_PORTUGUESE` | **33** |
| `enum_WATCH_LANGUAGE_TYPE_INDONESIAN` | **34** |
| `enum_WATCH_LANGUAGE_TYPE_MALAYSIAN` | **35** |
| `enum_WATCH_LANGUAGE_TYPE_VIETNAMESE` | **36** |
| `enum_WATCH_LANGUAGE_TYPE_BURMESE` | **37** |
| `enum_WATCH_LANGUAGE_TYPE_MONGOLIAN` | **38** |
| `enum_WATCH_LANGUAGE_TYPE_ALL` | **100** |
| `enum_WATCH_LANGUAGE_TYPE_CUSTOM` | **254** |

### `WatchConfig$WATCH_MENU_APPTYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_APPTYPE_INVALID` | **0** |
| `enum_WATCH_APPTYPE_DAILY` | **1** |
| `enum_WATCH_APPTYPE_STEP_COUNT` | **2** |
| `enum_WATCH_APPTYPE_CALORY` | **3** |
| `enum_WATCH_APPTYPE_INTENSE_DURATION` | **4** |
| `enum_WATCH_APPTYPE_DURATION` | **5** |
| `enum_WATCH_APPTYPE_SLEEP` | **6** |
| `enum_WATCH_APPTYPE_HRM` | **7** |
| `enum_WATCH_APPTYPE_BLOOD_OXYGEN` | **8** |
| `enum_WATCH_APPTYPE_PRESSURE` | **9** |
| `enum_WATCH_APPTYPE_HRV` | **10** |
| `enum_WATCH_APPTYPE_HISTORY` | **11** |
| `enum_WATCH_APPTYPE_RUNNING` | **12** |
| `enum_WATCH_APPTYPE_CYCLING` | **13** |
| `enum_WATCH_APPTYPE_SCHEDULES` | **14** |
| `enum_WATCH_APPTYPE_NAVIGATION` | **15** |
| `enum_WATCH_APPTYPE_TRAINING_STATUS` | **16** |
| `enum_WATCH_APPTYPE_TRAINING_LOAD` | **17** |
| `enum_WATCH_APPTYPE_TRAINING` | **18** |
| `enum_WATCH_APPTYPE_ALARM_CLOCK` | **19** |
| `enum_WATCH_APPTYPE_WEATHER` | **20** |
| `enum_WATCH_APPTYPE_STAMINA` | **21** |
| `enum_WATCH_APPTYPE_BREATHE` | **22** |
| `enum_WATCH_APPTYPE_SUN` | **23** |
| `enum_WATCH_APPTYPE_ALTITUDE` | **24** |
| `enum_WATCH_APPTYPE_BAROMETER` | **25** |
| `enum_WATCH_APPTYPE_COMPASS` | **26** |
| `enum_WATCH_APPTYPE_NOTIFICATION` | **27** |
| `enum_WATCH_APPTYPE_SETTING` | **28** |
| `enum_WATCH_APPTYPE_STAIRS_COUNT` | **29** |
| `enum_WATCH_APPTYPE_TRAINING_COURSES` | **30** |
| `enum_WATCH_APPTYPE_HISTORY_ACH` | **31** |

### `WatchConfig$WATCH_MENU_CONSOLETYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_CONSOLETYPE_INVALID` | **0** |
| `enum_WATCH_CONSOLETYPE_FOCUS_MODE` | **1** |
| `enum_WATCH_CONSOLETYPE_SLEEP_MODE` | **2** |
| `enum_WATCH_CONSOLETYPE_LOCK` | **3** |
| `enum_WATCH_CONSOLETYPE_LOCKALL` | **4** |
| `enum_WATCH_CONSOLETYPE_BRIGHTNESS` | **5** |
| `enum_WATCH_CONSOLETYPE_SENSOR` | **6** |
| `enum_WATCH_CONSOLETYPE_CAMERA` | **7** |
| `enum_WATCH_CONSOLETYPE_STOP_WATCH` | **8** |
| `enum_WATCH_CONSOLETYPE_TIMER` | **9** |
| `enum_WATCH_CONSOLETYPE_ALARMCLOCK` | **10** |
| `enum_WATCH_CONSOLETYPE_FLASHLIGHT` | **11** |
| `enum_WATCH_CONSOLETYPE_FIND_MY_PHONE` | **12** |
| `enum_WATCH_CONSOLETYPE_HRM` | **13** |
| `enum_WATCH_CONSOLETYPE_MUSIC` | **14** |
| `enum_WATCH_CONSOLETYPE_ALIPAY` | **15** |
| `enum_WATCH_CONSOLETYPE_RAISE_AWAKE` | **16** |
| `enum_WATCH_CONSOLETYPE_ALWAYS_ON` | **17** |
| `enum_WATCH_CONSOLETYPE_BATTERY_SAVE` | **18** |
| `enum_WATCH_CONSOLETYPE_SETTING` | **19** |
| `enum_WATCH_CONSOLETYPE_METRONOME` | **20** |
| `enum_WATCH_CONSOLETYPE_BREATH_TRAINING` | **21** |
| `enum_WATCH_CONSOLETYPE_IGP_LINK` | **22** |

### `WatchConfig$WATCH_MENU_SPORTTYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_SPORTSTYPE_INVALID` | **0** |
| `enum_WATCH_SPORTSTYPE_RUNNING` | **1** |
| `enum_WATCH_SPORTSTYPE_TREADMILL` | **2** |
| `enum_WATCH_SPORTSTYPE_PLAYGROUND` | **3** |
| `enum_WATCH_SPORTSTYPE_TRAIL_RUNNING` | **4** |
| `enum_WATCH_SPORTSTYPE_WALKING` | **5** |
| `enum_WATCH_SPORTSTYPE_INDOOR_RUNNING` | **6** |
| `enum_WATCH_SPORTSTYPE_CYCLING` | **11** |
| `enum_WATCH_SPORTSTYPE_INDOOR_CYCLING` | **12** |
| `enum_WATCH_SPORTSTYPE_ROAD_CYCLING` | **13** |
| `enum_WATCH_SPORTSTYPE_MOUNTAIN_CYCLING` | **14** |
| `enum_WATCH_SPORTSTYPE_COMMUTING` | **15** |
| `enum_WATCH_SPORTSTYPE_TRIP_CYCLING` | **16** |
| `enum_WATCH_SPORTSTYPE_POOL_SWIMMING` | **21** |
| `enum_WATCH_SPORTSTYPE_OPEN_WATER_SWIMMING` | **22** |
| `enum_WATCH_SPORTSTYPE_STRENGTH_TRAINING` | **31** |
| `enum_WATCH_SPORTSTYPE_INDOOR_AEROBIC` | **32** |
| `enum_WATCH_SPORTSTYPE_ELLIPTICAL_MACHINE` | **33** |
| `enum_WATCH_SPORTSTYPE_ROWING_MACHINE` | **34** |
| `enum_WATCH_SPORTSTYPE_MOUNTAINEERING` | **41** |
| `enum_WATCH_SPORTSTYPE_HIKING` | **42** |
| `enum_WATCH_SPORTSTYPE_SKIING` | **43** |
| `enum_WATCH_SPORTSTYPE_OUTDOOR_AEROBIC` | **44** |
| `enum_WATCH_SPORTSTYPE_JUMP_ROPE` | **51** |
| `enum_WATCH_SPORTSTYPE_TRIATHLON` | **52** |
| `enum_WATCH_SPORTSTYPE_COMPOUND_MOTION` | **53** |
| `enum_WATCH_SPORTSTYPE_EXERCISE` | **54** |
| `enum_WATCH_SPORTSTYPE_HIIT` | **61** |
| `enum_WATCH_SPORTSTYPE_ROWING_BOAT` | **62** |
| `enum_WATCH_SPORTSTYPE_PULP_BOARD` | **63** |
| `enum_WATCH_SPORTSTYPE_FITNESS` | **64** |
| `enum_WATCH_SPORTSTYPE_SNOWBOARDING` | **65** |
| `enum_WATCH_SPORTSTYPE_SNOWBOARDING_2` | **66** |
| `enum_WATCH_SPORTSTYPE_CROSS_COUNTRY_SKIING` | **67** |
| `enum_WATCH_SPORTSTYPE_YOGA` | **68** |
| `enum_WATCH_SPORTSTYPE_PILATES` | **69** |
| `enum_WATCH_SPORTSTYPE_OUTDOOR_FRISBEE` | **70** |

### `WatchConfig$WATCH_MENU_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_MENU_TYPE_INVALID` | **0** |
| `enum_WATCH_MENU_TYPE_APPS` | **1** |
| `enum_WATCH_MENU_TYPE_SPORTS` | **2** |
| `enum_WATCH_MENU_TYPE_TOOLS` | **3** |

### `WatchConfig$WATCH_PAGE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_PAGE_TYPE_INVALID` | **0** |
| `enum_WATCH_PAGE_TYPE_DATA` | **1** |
| `enum_WATCH_PAGE_TYPE_HRM` | **2** |
| `enum_WATCH_PAGE_TYPE_ALT` | **3** |
| `enum_WATCH_PAGE_TYPE_WKT_MONITOR` | **4** |
| `enum_WATCH_PAGE_TYPE_NAVI` | **5** |
| `enum_WATCH_PAGE_TYPE_STAGES` | **6** |
| `enum_WATCH_PAGE_TYPE_WKT` | **7** |
| `enum_WATCH_PAGE_TYPE_WKT_FEC` | **8** |
| `enum_WATCH_PAGE_TYPE_NAVI_ALT` | **9** |
| `enum_WATCH_PAGE_TYPE_NAVI_INFO` | **10** |
| `enum_WATCH_PAGE_TYPE_COMPASS` | **11** |
| `enum_WATCH_PAGE_TYPE_LAP` | **12** |
| `enum_WATCH_PAGE_TYPE_BUNNY` | **13** |
| `enum_WATCH_PAGE_TYPE_OTHER` | **14** |

### `WatchConfig$WATCH_SECTION_HR_TYPE`

| Constante | Valeur |
|---|---|
| `WATCH_SECTION_HR_TYPE_INVALID` | **0** |
| `WATCH_SECTION_HR_TYPE_MAX` | **1** |
| `WATCH_SECTION_HR_TYPE_LTHR` | **2** |
| `WATCH_SECTION_HR_TYPE_RESERVE_HR` | **3** |

### `WatchConfig$WATCH_SECTION_SPORT_TYPE`

| Constante | Valeur |
|---|---|
| `WATCH_SECTION_SPORT_TYPE_INVALID` | **0** |
| `WATCH_SECTION_SPORT_TYPE_RUN` | **1** |
| `WATCH_SECTION_SPORT_TYPE_RIDE` | **2** |
| `WATCH_SECTION_SPORT_TYPE_SWIM` | **3** |

### `WatchConfig$WATCH_SEX_TYPE`

| Constante | Valeur |
|---|---|
| `G_WATCH_FEMALE` | **0** |
| `G_WATCH_MALE` | **1** |
| `G_WATCH_CONFIDENTIAL` | **2** |

### `WatchConfig$WATCH_TIME_SYSTEM_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_TIME_SYSTEM_TYPE_12HOUR` | **1** |
| `enum_WATCH_TIME_SYSTEM_TYPE_24HOUR` | **2** |

### `WatchConfig$WATCH_UNIT_ITEM`

| Constante | Valeur |
|---|---|
| `enum_WATCH_UNIT_ITEM_INVALID` | **0** |
| `enum_WATCH_UNIT_ITEM_DISTANCE` | **1** |
| `enum_WATCH_UNIT_ITEM_ELEVATION` | **2** |
| `enum_WATCH_UNIT_ITEM_WEIGHT` | **3** |
| `enum_WATCH_UNIT_ITEM_TEMPERATURE` | **4** |
| `enum_WATCH_UNIT_ITEM_LENGTH` | **5** |
| `enum_WATCH_UNIT_ITEM_POOL_LENGTH` | **6** |

### `WatchConfig$WATCH_UNIT_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_UNIT_TYPE_INVALID` | **0** |
| `enum_WATCH_UNIT_TYPE_METRIC` | **1** |
| `enum_WATCH_UNIT_TYPE_INCH` | **2** |

### `WatchConfig$WATCH_WEAR_HAND_TYPE`

| Constante | Valeur |
|---|---|
| `G_WATCH_WEAR_HAND_LEFT` | **0** |
| `G_WATCH_WEAR_HAND_RIGHT` | **1** |

### `WatchConfig$WATCH_WEBGRID_MODE`

| Constante | Valeur |
|---|---|
| `WATCH_WEBGRID_MODE_INVALID` | **0** |
| `WATCH_WEBGRID_MODE_STANDARD` | **1** |
| `WATCH_WEBGRID_MODE_SPECIAL_GRID` | **2** |

### `WatchDial$WATCH_DIAL_ADD_STATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_DIAL_ADD_ALLOW` | **0** |
| `enum_WATCH_DIAL_ADD_DISALLOW_UNZIPPING` | **1** |
| `enum_WATCH_DIAL_ADD_DISALLOW_MAX_LIMIT` | **2** |
| `enum_WATCH_DIAL_ADD_DISALLOW_EXERCISING` | **3** |
| `enum_WATCH_DIAL_ADD_DISALLOW_EXIST` | **4** |
| `enum_WATCH_DIAL_ADD_DISALLOW_GUIDE` | **5** |
| `enum_WATCH_DIAL_ADD_DISALLOW_EDITING` | **6** |
| `enum_WATCH_DIAL_ADD_DISALLOW_IN_USE` | **7** |

### `WatchDial$WATCH_DIAL_COLOR_TYPE_E`

| Constante | Valeur |
|---|---|
| `enum_WATCH_DIAL_COLOR_TYPE_INVALID` | **0** |
| `enum_WATCH_DIAL_COLOR_TYPE_MAGENTA` | **1** |
| `enum_WATCH_DIAL_COLOR_TYPE_RED1` | **2** |
| `enum_WATCH_DIAL_COLOR_TYPE_GREEN1` | **3** |
| `enum_WATCH_DIAL_COLOR_TYPE_BLUE1` | **4** |
| `enum_WATCH_DIAL_COLOR_TYPE_YELLOW1` | **5** |
| `enum_WATCH_DIAL_COLOR_TYPE_CYAN1` | **6** |
| `enum_WATCH_DIAL_COLOR_TYPE_LIGHT_STEEL_BLUE_SIMI` | **7** |

### `WatchDial$WATCH_DIAL_DATA_TYPE_E`

| Constante | Valeur |
|---|---|
| `enum_WATCH_DIAL_DATA_TYPE_INVALID` | **0** |
| `enum_WATCH_DIAL_DATA_TYPE_HR` | **1** |
| `enum_WATCH_DIAL_DATA_TYPE_STRESS` | **2** |
| `enum_WATCH_DIAL_DATA_TYPE_STEP` | **3** |
| `enum_WATCH_DIAL_DATA_TYPE_CAL` | **4** |
| `enum_WATCH_DIAL_DATA_TYPE_INTENSE` | **5** |
| `enum_WATCH_DIAL_DATA_TYPE_RUN_VO2MAX` | **6** |
| `enum_WATCH_DIAL_DATA_TYPE_RIDE_VO2MAX` | **7** |
| `enum_WATCH_DIAL_DATA_TYPE_BATTERY` | **8** |
| `enum_WATCH_DIAL_DATA_TYPE_ALTITUDE` | **9** |
| `enum_WATCH_DIAL_DATA_TYPE_BAROMETRIC` | **10** |
| `enum_WATCH_DIAL_DATA_TYPE_WEATHER` | **11** |
| `enum_WATCH_DIAL_DATA_TYPE_ALIPAY` | **12** |
| `enum_WATCH_DIAL_DATA_TYPE_COMPASS` | **13** |
| `enum_WATCH_DIAL_DATA_TYPE_ALARM` | **14** |
| `enum_WATCH_DIAL_DATA_TYPE_STOPWATCH` | **15** |
| `enum_WATCH_DIAL_DATA_TYPE_TIMER` | **16** |
| `enum_WATCH_DIAL_DATA_TYPE_HR_PUSH` | **17** |

### `WatchDial$WATCH_DIAL_OPERATION_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_DIAL_OPERATION_TYPE_NONE` | **0** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_CURRENT_GET` | **1** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_ADD` | **2** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_DELETE` | **3** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_LIST_GET` | **4** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_LIST_NUM_GET` | **5** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_CFG_GET` | **6** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_CFG_SET` | **7** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_USE` | **8** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_INFO_GET` | **9** |
| `enum_WATCH_DIAL_OPERATION_TYPE_WATCH_DIAL_ADD_STATE_GET` | **10** |

### `WatchDial$WATCH_DIAL_TIME_POSITION_TYPE_E`

| Constante | Valeur |
|---|---|
| `enum_WATCH_DIAL_TIME_POSITION_TYPE_INVALID` | **0** |
| `enum_WATCH_DIAL_TIME_POSITION_TYPE_TOP` | **1** |
| `enum_WATCH_DIAL_TIME_POSITION_TYPE_CENTER` | **2** |
| `enum_WATCH_DIAL_TIME_POSITION_TYPE_BOTTOM` | **3** |

### `WatchDial$WATCH_DIAL_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_DIAL_TYPE_INVALID` | **0** |
| `enum_WATCH_DIAL_TYPE_SYSTEM` | **1** |
| `enum_WATCH_DIAL_TYPE_PHOTO` | **2** |
| `enum_WATCH_DIAL_TYPE_STORE` | **3** |

### `WatchHealthData$WATCH_DAILY_ACTIVITY_TYPE`

| Constante | Valeur |
|---|---|
| `WATCH_DAILY_ACTIVITY_TYPE_NONE` | **0** |
| `WATCH_DAILY_ACTIVITY_TYPE_STEP` | **1** |
| `WATCH_DAILY_ACTIVITY_TYPE_CALORIES` | **2** |
| `WATCH_DAILY_ACTIVITY_TYPE_INTENSE_TIME` | **3** |
| `WATCH_DAILY_ACTIVITY_TYPE_ACTIVE_HOUR` | **4** |

### `WatchHealthData$WATCH_DAILY_ALARM_TYPE`

| Constante | Valeur |
|---|---|
| `WATCH_DAILY_ALARM_TYPE_NONE` | **0** |
| `WATCH_DAILY_ALARM_TYPE_STAND` | **1** |
| `WATCH_DAILY_ALARM_TYPE_DRINK` | **2** |

### `WatchHealthData$WATCH_HEALTH_DATA_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_NONE` | **0** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_REAL_TIME_GET` | **1** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_HISTORY_GET` | **3** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_DLY_ACT_TARGET_GET` | **5** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_DLY_ACT_TARGET_SET` | **7** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_DLY_ACT_ALARM_GET` | **8** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_DLY_ACT_ALARM_SET` | **10** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_DLY_ACT_DATA_SYNC` | **11** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_HISTORY_FILE_PACKAGED` | **12** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_HISTORY_FILE_GET` | **13** |
| `enum_WATCH_HEALTH_DATA_OPERATE_TYPE_HISTORY_LIST_GET` | **15** |

### `WatchHealthData$WATCH_HEALTH_DATA_TYPE`

| Constante | Valeur |
|---|---|
| `WATCH_HEALTH_DATA_DEFAULT` | **0** |
| `WATCH_HEALTH_DATA_SLEEP` | **1** |
| `WATCH_HEALTH_DATA_STRESS` | **2** |
| `WATCH_HEALTH_DATA_HEART_RATE` | **3** |
| `WATCH_HEALTH_DATA_SPO2` | **4** |
| `WATCH_HEALTH_DATA_HEART_RATE_VARIABILITY` | **5** |
| `WATCH_HEALTH_DATA_DAILY_ACTIVITY` | **6** |
| `WATCH_HEALTH_DATA_RESTING_HR` | **7** |

### `Wifi$WIFI_ENCRYPT_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WIFI_ENCRYPT_TYPE_NONE` | **0** |
| `enum_WIFI_ENCRYPT_TYPE_OPEN` | **1** |
| `enum_WIFI_ENCRYPT_TYPE_WEP_PSK` | **2** |
| `enum_WIFI_ENCRYPT_TYPE_WPA_TKIP_PSK` | **3** |
| `enum_WIFI_ENCRYPT_TYPE_WPA_TKIP_8021X` | **4** |
| `enum_WIFI_ENCRYPT_TYPE_WPA_AES_PSK` | **5** |
| `enum_WIFI_ENCRYPT_TYPE_WPA_AES_8021X` | **6** |
| `enum_WIFI_ENCRYPT_TYPE_WPA2_AES_PSK` | **7** |
| `enum_WIFI_ENCRYPT_TYPE_WPA2_AES_8021X` | **8** |
| `enum_WIFI_ENCRYPT_TYPE_WPA2_TKIP_PSK` | **9** |
| `enum_WIFI_ENCRYPT_TYPE_WPA2_TKIP_8021X` | **10** |
| `enum_WIFI_ENCRYPT_TYPE_WPA2_MIXED_PSK` | **11** |
| `enum_WIFI_ENCRYPT_TYPE_WPA_WPA2_MIXED_PSK` | **12** |
| `enum_WIFI_ENCRYPT_TYPE_WPA_WPA2_MIXED_8021X` | **13** |
| `enum_WIFI_ENCRYPT_TYPE_WPA3` | **14** |

### `Wifi$WIFI_OPERATE_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WIFI_OPERATE_TYPE_NONE` | **0** |
| `enum_WIFI_OPERATE_TYPE_STATUS_GET` | **1** |
| `enum_WIFI_OPERATE_TYPE_STATUS_SEND` | **2** |
| `enum_WIFI_OPERATE_TYPE_CTRL` | **3** |
| `enum_WIFI_OPERATE_TYPE_LIST_GET` | **4** |
| `enum_WIFI_OPERATE_TYPE_LIST_SEND` | **5** |
| `enum_WIFI_OPERATE_TYPE_ASSIGN_SSID` | **6** |
| `enum_WIFI_OPERATE_TYPE_AUTO_STATUS_GET` | **7** |
| `enum_WIFI_OPERATE_TYPE_AUTO_STATUS_SEND` | **8** |
| `enum_WIFI_OPERATE_TYPE_AUTO_STATUS_SET` | **9** |
| `enum_WIFI_OPERATE_TYPE_DELETE_SSID` | **10** |
| `enum_WIFI_OPERATE_TYPE_SYNC_STATES_GET` | **11** |
| `enum_WIFI_OPERATE_TYPE_STORED_LIST_GET` | **12** |
| `enum_WIFI_OPERATE_TYPE_URL_SEND` | **13** |
| `enum_WIFI_OPERATE_TYPE_CPU_UUID_GET` | **14** |
| `enum_WIFI_OPERATE_TYPE_QUICK_UPGRADE` | **15** |

### `Wifi$WIFI_SYNC_TYPE`

| Constante | Valeur |
|---|---|
| `enum_WIFI_SYNC_TYPE_ACTIVITY` | **1** |
| `enum_WIFI_SYNC_TYPE_AGPS` | **2** |
| `enum_WIFI_SYNC_TYPE_FIRMWARE` | **3** |

## Champs des messages

- **`AlgGmData$pb_gm_format_msg`** — `bitField0`, `operateType`, `persistentData`, `serviceType`
- **`AlgGmData$pb_gm_historical_data`** — `records`
- **`AlgGmData$pb_gm_historical_record`** — `bitField0`, `fTP`, `mAP`, `timestamp`, `tlTrend`, `trainingLoad`, `trainingStatus`, `vO2Max`
- **`AlgGmData$pb_gm_persistent_data`** — `bitField0`, `historical`, `statistical`
- **`AlgGmData$pb_gm_statistical_outputs`** — `aerobicAbiltiy`, `aerobicPowerAbility`, `anaerobicAbility`, `bitField0`, `endTime`, `enduranceAbiltiy`, `fTP`, `lTHR`, `mAP`, `pHRZ`, `pWR`, `powerAbility`, `recoveryTime`, `stamina`, `staminaLevel`, `startTime`, `tlTrend`, `trainingLoad`, `trainingStatus`, `ultraEnduranceAbility`, `vO2Max`
- **`AppWatch$watch_control_format`** — `bitField0`, `deviceInfo`, `operateType`, `serviceType`, `subServiceType`
- **`AppWatch$watch_device_info_message`** — `bitField0`, `deviceName`, `manufaInfor`
- **`Back$air_pressure_data_message`** — `airPressure`, `bitField0`
- **`Back$back_msg`** — `airPressureMsg`, `backOperateType`, `backServiceType`, `bitField0`, `curMsg`, `ephemerisDataMsg`, `locateInfoMsg`, `serviceType`, `threeDaysMsg`, `threeHoursMsg`, `timeMsg`
- **`Back$ephemeris_data_message`** — `agpsType`, `bitField0`, `contents`, `fileName`, `gpsType`, `time`
- **`Back$locate_info_data_message`** — `bitField0`, `latitude`, `longitude`
- **`Back$time_data_message`** — `bitField0`, `time`, `timeZone`, `utcTimestampMs`
- **`Back$weather_current_data_message`** — `airQuality`, `bitField0`, `curDayMaxTemp`, `curDayMinTemp`, `curTemperature`, `curWeather`, `humidity`, `region`, `time`, `windDeg`, `windSpd`
- **`Back$weather_three_days_data_message`** — `bitField0`, `date`, `maxTemp`, `minTemp`, `rainProb`, `sunRiseTime`, `sunSetTime`, `weatherIndex`
- **`Back$weather_three_hour_data_memsage`** — `bitField0`, `rainProb`, `temp`, `time`, `watherIndex`, `windDeg`, `windSpd`
- **`Ble$ble_bond_status_message`** — `bitField0`, `bondStatus`
- **`Ble$ble_data_message`** — `bitField0`, `memberId`, `status`
- **`Ble$ble_msg`** — `bitField0`, `bleBondStatusMsg`, `bleBondUserMsg`, `bleDataMsg`, `bleOperateType`, `serviceType`
- **`Ble$watch_ble_bond_user_message`** — `bitField0`, `bondAllow`, `memberIdCheckStatus`, `state`, `userId`
- **`CloudSwitchDev$cloud_switch_dev_message`** — `bitField0`, `operateType`, `serviceType`
- **`Common$file_list_get_message`** — `bitField0`, `fileIndexEnd`, `fileIndexStart`, `fileListSupportNumMax`, `fileNum`, `supportMaxFileNum`
- **`Config$accident_detection_msg`** — `accidentDetectionModeIndex`, `accidentDetectionOpen`, `bitField0`
- **`Config$alarm_msg`** — `alarmIntervalTime`, `bitField0`, `setMsg`
- **`Config$alarm_params_set_msg`** — `alarmType`, `bitField0`, `selectInfo`, `selectType`, `status`, `valueMax`, `valueMin`
- **`Config$alarm_select_info`** — `bitField0`, `selectType`, `value`
- **`Config$auto_set_msg`** — `autoType`, `bitField0`, `param1`, `status`
- **`Config$backlight_msg`** — `backlightAuto`, `backlightDayPercent`, `backlightNightOn`, `backlightNightPercent`, `backlingTime`, `bitField0`
- **`Config$bike_msg`** — `autoDia`, `bikeIndex`, `bikeName`, `bikeStatus`, `bikeWeigth`, `bitField0`, `odometer`, `wheelDia`
- **`Config$config_msg`** — `accidentDetectionMessage`, `alarmMessage`, `altitude`, `autoSetMessage`, `backlightMessage`, `bikeMessage`, `bitField0`, `configOperateType`, `configSeviceType`, `curOperateMode`, `dataMessage`, `keySetMessage`, `languageMessage`, `lapMessage`, `modeConfigMessage`, `modeMessage`, `pageMessage`, `pageStatusMessage`, `passwordMessage`, `serviceType`, `soundSetMessage`, `timeSystem`, `unitMessage`, `userDataMessage`
- **`Config$cur_page_status_msg`** — `bitField0`, `dataPageNumMax`, `lcdType`, `mainPageOpen`, `pageLineDataMax`, `pageLineNumMax`, `supportPageLayout`, `unsupportData`
- **`Config$data_msg`** — `bitField0`, `dataType`, `status`
- **`Config$emergency_contact_msg`** — `areaCode`, `bitField0`, `email`, `name`, `phone`
- **`Config$key_set_msg`** — `bitField0`, `keyFunctionType`, `keySupport`, `keySupport_converter`, `keyType`
- **`Config$language_msg`** — `bitField0`, `curLanguage`, `supportedLanguage`, `supportedLanguage_converter`
- **`Config$lap_msg`** — `bitField0`, `lapType`, `status`, `value`
- **`Config$mode_config_msg`** — `bitField0`, `defaultModeNum`, `maxModeNum`
- **`Config$mode_msg`** — `bitField0`, `inuse`, `modeColor`, `modeIndex`, `modeName`, `templateIndex`, `valid`
- **`Config$page_msg`** — `bitField0`, `data`, `dataSite`, `forbiddenClose`, `graphicDisplay`, `lineWidth`, `mainPageStatus`, `pageIndex`, `pageMode`, `pageName`, `pageType`, `status`
- **`Config$password_msg`** — `bitField0`, `password`
- **`Config$section_data_msg`** — `bitField0`, `cad`, `fTP`, `hrm`, `power`, `rideHrType`, `rideHrm`, `rideLacticAcidHrm`, `rideReserveHr`, `spd`
- **`Config$sound_set_msg`** — `bitField0`, `soundScene`, `soundType`, `status`
- **`Config$unit_msg`** — `bitField0`, `unitItem`, `unitType`
- **`Config$user_data_msg`** — `age`, `bitField0`, `emergencyContact`, `height`, `memberId`, `personalInforChangeTime`, `restHr`, `rideHrLacticAcid`, `rideHrMax`, `sectionData`, `sex`, `timeZone`, `updateStatus`, `weight`
- **`CyclingData$cycling_data_auto_upload_message`** — `bitField0`, `cyclingDataCheckUrl`, `cyclingDataUrl`, `status`
- **`CyclingData$cycling_data_file_flag_message`** — `bitField0`, `deviceId`, `fileSize`, `timestamp`, `userId`
- **`CyclingData$cycling_data_msg`** — `bitField0`, `cyclingDataAutoUploadMsg`, `cyclingDataFileFlagMsg`, `cyclingDataOperateType`, `fileContent`, `listMsg`, `serviceType`
- **`DevStatus$dev_cycling_status_massage`** — `bitField0`, `cyclingStartTime`, `devCyclingStatus`
- **`DevStatus$dev_gps_massage`** — `bitField0`, `latitude`, `longitude`
- **`DevStatus$dev_position_point`** — `bitField0`, `latitude`, `longitude`, `pointIndex`, `pointname`
- **`DevStatus$dev_position_point_group`** — `bitField0`, `positionInfo`, `positionPointNum`
- **`DevStatus$dev_status_msg`** — `bitField0`, `devCyclingStatusMsg`, `devGpsMsg`, `naviStatus`, `opType`, `positionPointManager`, `rtDataMsg`, `serviceType`, `wifiStatus`
- **`DevStatus$rt_data_message`** — `avgCad`, `avgHrm`, `avgPower`, `avgRise`, `avgSpeed`, `bitField0`, `course`, `curHeight`, `curSlope`, `maxCad`, `maxHrm`, `maxPower`, `maxSpeed`, `realTimeCad`, `realTimeHrm`, `realTimePower`, `realTimeSpeed`, `ridingDistance`, `ridingTime`, `totalHeight`
- **`DevVerInfo$dev_ver_info_msg`** — `bitField0`, `operateType`, `serviceType`, `versionMessage`
- **`DevVerInfo$version_msg`** — `bitField0`, `bleAppVer`, `bleBootVer`, `compileTime`, `hardwareVer`, `mainAppVer`, `mainBootVer`, `protocolVer`
- **`DeviceInformation$DeviceImage`** — `imageType`, `url`
- **`DeviceInformation$DeviceInfo`** — `androidSupportMinVersion`, `connectionMode`, `dataReceiveTimeOut`, `devCustomName`, `devName`, `deviceCategoryType`, `deviceImage`, `deviceMaxActivityFileNum`, `ephemerisEffectiveTime`, `functionTypeList`, `functionTypeList_converter`, `generation`, `isAccessory`, `isShowRecommendDevice`, `isSupportAuth`, `isSupportProtoBuf`, `manufacturerSpecificData`, `mapManual`, `pagingInformation`, `pairMode`, `sendFileMtuSize`, `upperLimitOfMode`
- **`DeviceInformation$MapManual`** — `manualType`, `url`
- **`DeviceInformation$PagingInformation`** — `function`, `isSupportPaging`
- **`EmojiLight$emoji_base_msg`** — `batPct`, `colSize`, `curEmoji`, `emojiCnt`, `maxEmojiCnt`, `rawSize`, `savedMsg`, `version`
- **`EmojiLight$emoji_delete_msg`** — `uid`
- **`EmojiLight$emoji_detail_msg`** — `attr`, `emojiName`, `intensity`, `isGlobalIntensity`, `modeIndex`, `uid`
- **`EmojiLight$emoji_index_msg`** — `emojiMode`
- **`EmojiLight$emoji_msg_format`** — `emojiOperate`, `emojiService`, `msgAll`, `operateType`, `serviceType`
- **`EmojiLight$emoji_msgs_all`** — `baseMsg`, `delete`, `detail`, `myAbbrEmoji`, `single`
- **`EmojiLight$my_emoji_abbr_msg`** — `savedMsg`, `uidInUsing`
- **`EmojiLight$single_emoji_pb_stream_msg`** — `pbData`, `size`
- **`Factory$ant_message`** — `bitField0`, `data`, `devConnectStatus`, `devType`
- **`Factory$battary_message`** — `bitField0`, `powerPercent`, `voltage`
- **`Factory$control_message`** — `bitField0`, `cmdType`, `status`
- **`Factory$data_set_message`** — `bitField0`, `dataType`, `value`
- **`Factory$factory_msg`** — `antMsg`, `battaryMsg`, `bitField0`, `controlMsg`, `dataSetMsg`, `factoryOperateType`, `factorySensorMsg`, `factorySnMsg`, `filterMsg`, `gpsCmdMsg`, `gpsControlCmdMsg`, `gpsCoordinateMsg`, `gpsDynamicMsg`, `gpsGnssMsg`, `gpsSnrMsg`, `memoryMsg`, `powerSaveMsg`, `rtcMsg`, `serviceType`, `simFitMsg`, `sunTimeMsg`
- **`Factory$factory_sensor_message`** — `bitField0`, `data`, `sensorType`, `status`
- **`Factory$factory_sn_message`** — `bitField0`, `goMoreKey`, `sn`
- **`Factory$filter_message`** — `bitField0`, `filterType`, `status`
- **`Factory$gps_cmd_message`** — `gpsCmd`
- **`Factory$gps_control_cmd_message`** — `bitField0`, `gpsCmdType`, `status`
- **`Factory$gps_coordinate_message`** — `bitField0`, `latitude`, `longitude`
- **`Factory$gps_dynamic_message`** — `bitField0`, `gpsDynamicType`
- **`Factory$gps_gnss_message`** — `bitField0`, `gnssGnssCmd`
- **`Factory$gps_snr_massage`** — `bitField0`, `data`, `gnssType`
- **`Factory$memory_message`** — `bitField0`, `remain`, `total`
- **`Factory$power_save_message`** — `bitField0`, `time`
- **`Factory$rtc_message`** — `bitField0`, `time`
- **`Factory$sim_fit_message`** — `bitField0`, `num`, `size`
- **`Factory$sun_time_message`** — `bitField0`, `sunriseTime`, `sunsetTime`
- **`FileDownload$file_download`** — `bitField0`, `fileCrc32`, `fileId`, `fileName`, `fileSize`, `fileType`, `fileVerifyVal`
- **`Firmware$firmware_auto_download_status_message`** — `bitField0`, `status`
- **`Firmware$firmware_data_message`** — `bitField0`, `bleBootFirmwareVer`, `bleFirmwareVer`, `firmwareSize`, `mcuFirmwareVer`, `process`, `resourceVer`, `url`
- **`Firmware$firmware_msg`** — `bitField0`, `firmwareAutoDownloadStatusMsg`, `firmwareDataMsg`, `firmwareOperateType`, `serviceType`
- **`GeneralFileOperation$file_extra_Info`** — `avgSlope`, `bitField0`, `distance`, `routePackId`, `routePackName`, `routePackRouteNum`, `totalAscent`
- **`GeneralFileOperation$file_transfer_method_information`** — `bitField0`, `packetAckSupported`, `resumeOffset`, `resumeSupported`
- **`GeneralFileOperation$general_file_operation`** — `bitField0`, `extraInfo`, `fileExtension`, `fileId`, `fileMd5`, `fileName`, `fileSize`, `fileType`, `fileVerifyVal`, `isTemp`, `methodInformation`, `operateType`, `serviceType`, `watchPhotoDialExtraInfo`
- **`GeneralFileOperation$watch_photo_dial_extra_Info`** — `bitField0`, `color`, `dialId`, `dialType`, `num`, `timePositionType`
- **`GroupRide$group_ride_ctrl_msg`** — `bitField0`, `groupRideCode`, `groupRideId`, `reason`, `status`
- **`GroupRide$group_ride_infor_msg`** — `bitField0`, `latitude`, `longitude`, `memberId`, `sos`, `status`, `strightLineDistance`
- **`GroupRide$group_ride_message`** — `bitField0`, `ctrl`, `msgType`, `onlineStatus`, `operateType`, `personalInfor`, `rideInfor`, `serviceType`
- **`GroupRide$online_status_msg`** — `bitField0`, `groupRideId`, `status`
- **`GroupRide$personal_infor_msg`** — `bitField0`, `isOwner`, `memberId`, `memberIdentity`, `nikename`
- **`Ins$ancs_filter_message`** — `appIdentifier`, `bitField0`, `catagoryId`, `status`
- **`Ins$ins_data_message`** — `apkName`, `appName`, `bitField0`, `content`, `count`, `isApp`, `name`, `pairingCode`, `telNum`, `time`, `uid`
- **`Ins$ins_msg`** — `ancsFilterMsg`, `bitField0`, `config`, `insDataMsg`, `insOperateType`, `insServiceType`, `serviceType`
- **`LanguagePack$language_pack_info_msg`** — `bitField0`, `fontSize`, `fontType`, `languageType`, `languageVersin`, `md5Code`, `packSize`, `url`
- **`LanguagePack$language_pack_module_info_msg`** — `bitField0`, `languagePackModuleVersion`, `supportCmd`, `supportCmd_converter`
- **`LanguagePack$language_pack_msg`** — `bitField0`, `content`, `languagePackInfoMessage`, `languageSubOperate`, `moduleInfoMessage`, `operateType`, `serviceType`
- **`Log$log_msg`** — `bitField0`, `content`, `logName`, `logNum`, `logType`, `operate`, `service`, `subOperate`
- **`Map$map_data_message`** — `areaId`, `areaType`, `bitField0`, `config`, `mapId`, `progress`, `size`, `url`, `version`
- **`Map$map_msg`** — `bitField0`, `mapDataMsg`, `mapOperateType`, `serviceType`
- **`Media$media_message`** — `bitField0`, `operateType`, `playerMsg`, `queueMsg`, `serviceType`, `status`, `trackMsg`
- **`Media$player_message`** — `bitField0`, `elapsedTime`, `playerName`, `playerRate`, `playerState`, `volumeCur`, `volumeMax`
- **`Media$queue_message`** — `bitField0`, `mode`, `queueCount`, `queueIndex`
- **`Media$track_message`** — `album`, `artist`, `bitField0`, `title`, `totalTime`
- **`PeripheralConfig$peripheral_config_data_broadcast`** — `dataSwitch`
- **`PeripheralConfig$peripheral_config_data_shutdown`** — `countdown`, `shutdownSwitch`
- **`PeripheralConfig$peripheral_config_data_sleep`** — `countdown`, `sleepSwitch`
- **`PeripheralConfig$peripheral_config_format`** — `message`, `operateType`, `serviceType`, `subOperateType`, `subServiceType`
- **`PeripheralConfig$peripheral_config_light_mode`** — `lightMode`
- **`PeripheralConfig$peripheral_config_message`** — `dataService`, `light`, `shutdown`, `sleep`
- **`PeripheralFactory$peripheral_factory_data_ant_id`** — `antId`
- **`PeripheralFactory$peripheral_factory_data_bsp_acc`** — `xAxisVal`, `yAxisVal`, `zAxisVal`
- **`PeripheralFactory$peripheral_factory_data_bsp_battery`** — `percent`, `volCur`
- **`PeripheralFactory$peripheral_factory_data_bsp_lsr`** — `lightness`
- **`PeripheralFactory$peripheral_factory_data_bsp_memory`** — `remainIexternalFlash`, `remainInternalFlash`, `totalExternalFlash`, `totalInternalFlash`
- **`PeripheralFactory$peripheral_factory_data_bsp_radar_raw`** — `amplitude`, `frequency`
- **`PeripheralFactory$peripheral_factory_data_bsp_radar_test`** — `radarTestCmd`, `radarTestData`
- **`PeripheralFactory$peripheral_factory_data_bsp_rtc`** — `rtc`, `sunrise`, `sunset`, `zone`
- **`PeripheralFactory$peripheral_factory_data_bsp_temperature`** — `tempCur`, `tempMax`
- **`PeripheralFactory$peripheral_factory_data_capacitance`** — `capacitance`, `capacitanceCollect`, `capacitanceReference`, `diffCollect`, `diffReference`
- **`PeripheralFactory$peripheral_factory_data_device_config`** — `shutdown`, `sleep`
- **`PeripheralFactory$peripheral_factory_data_device_info`** — `id`, `model`, `name`, `version`
- **`PeripheralFactory$peripheral_factory_data_device_operate`** — `hrSportMode`
- **`PeripheralFactory$peripheral_factory_data_fcal_result`** — `result`
- **`PeripheralFactory$peripheral_factory_data_ppg_test_data`** — `baseNoiseValues`, `ctrValues`, `dcOffsetValues`, `firstErrorCode`, `firstFailedChannel`, `leakRatioValues`, `llpctrValues`, `noiseValues`, `snrValues`, `state`, `testType`
- **`PeripheralFactory$peripheral_factory_data_radar_snr`** — `noise`, `signal`, `snr`
- **`PeripheralFactory$peripheral_factory_data_sn`** — `sn`
- **`PeripheralFactory$peripheral_factory_data_therm_vol`** — `vol`
- **`PeripheralFactory$peripheral_factory_data_void_welding`** — `anaVal`, `channel1`, `channel2`, `channel3`, `channel4`, `f7RegAddr`, `lockState`, `lockVal`
- **`PeripheralFactory$peripheral_factory_format`** — `message`, `operateType`, `serviceType`, `subOperateType`, `subServiceType`
- **`PeripheralFactory$peripheral_factory_message`** — `ant`, `bspAcc`, `bspBattery`, `bspLsr`, `bspMemory`, `bspRtc`, `bspTemperature`, `capacitance`, `deviceConfig`, `deviceInfo`, `deviceOperate`, `fcalResult`, `otaData`, `ppgTestData`, `radarTest`, `selfTest`, `sn`, `thermVol`, `voidWelding`
- **`PeripheralFactory$peripheral_self_test_result`** — `result`
- **`PeripheralFactory$ppg_channel_value`** — `channelIdx`, `value`
- **`PeripheralFirmware$peripheral_firmware_format`** — `message`, `operateType`, `serviceType`, `subOperateType`, `subServiceType`
- **`PeripheralFirmware$peripheral_firmware_message`** — `binPacketData`, `binPacketSize`, `binTotalSize`
- **`PeripheralHr$peripheral_hr_data_sport_mode`** — `keySwitch`, `mode`
- **`PeripheralHr$peripheral_hr_data_warn`** — `highSwitch`, `highValue`, `highWarnType`, `lowSwitch`, `lowValue`, `lowWarnType`, `warnSwitch`
- **`PeripheralHr$peripheral_hr_data_zone`** — `value`
- **`PeripheralHr$peripheral_hr_format`** — `message`, `operateType`, `serviceType`, `subOperateType`, `subServiceType`
- **`PeripheralHr$peripheral_hr_message`** — `hrZone`, `hrmWarn`, `sportMode`
- **`PeripheralInfo$peripheral_info_data_id`** — `deviceId`, `manufacturerId`
- **`PeripheralInfo$peripheral_info_data_memory`** — `remainExternalRam`, `remainIexternalFlash`, `remainInternalFlash`, `remainInternalRam`, `totalExternalFlash`, `totalExternalRam`, `totalInternalFlash`, `totalInternalRam`
- **`PeripheralInfo$peripheral_info_data_name`** — `bleName`, `deviceName`, `manufacturerName`
- **`PeripheralInfo$peripheral_info_data_power`** — `percent`, `volCur`
- **`PeripheralInfo$peripheral_info_data_temperature`** — `tempCur`, `tempMax`
- **`PeripheralInfo$peripheral_info_data_version`** — `appVersion`, `bootVersion`, `checkVersion`, `hardVersion`, `mcuVersion`, `supportCommonMcuUpgrade`
- **`PeripheralInfo$peripheral_info_format`** — `message`, `operateType`, `serviceType`, `subOperateType`, `subServiceType`
- **`PeripheralInfo$peripheral_info_message`** — `id`, `memory`, `model`, `name`, `power`, `temperature`, `version`
- **`PeripheralLight$auto_low_cfg`** — `status`, `timeOut`
- **`PeripheralLight$auto_pwr_cfg`** — `status`
- **`PeripheralLight$custome_mode_config`** — `cycle`, `mLightness`, `mode`, `pLightness`, `ratio`
- **`PeripheralLight$peripheral_auto_config_message`** — `autoLight`, `autoLow`, `autoPwr`, `autoSleep`, `brakeSwtich`, `sleepCnt`, `syncOff`, `teamRide`
- **`PeripheralLight$peripheral_light_format`** — `message`, `operateType`, `serviceType`, `subOperateType`, `subServiceType`
- **`PeripheralLight$peripheral_light_message`** — `autoConfig`, `autolightFlag`, `curMode`, `cusConfig`, `cusMode`, `lightCfgSup`, `lightCfgSup_converter`, `lightModesSupport`, `lightModesSupport_converter`, `lightType`, `offFlag`, `remainTime`, `sleepFlag`
- **`PeripheralLightApp$blt_bat_pct`** — `batPct`
- **`PeripheralLightApp$blt_cus_mode_arg`** — `cusMode`, `mode`, `selected`
- **`PeripheralLightApp$blt_cus_mode_cfg`** — `lightnessMap`, `speCycle`, `speRatio`, `subtype`
- **`PeripheralLightApp$blt_cus_mode_cfg$spe_flicker_cycle`** — `cycle`
- **`PeripheralLightApp$blt_cus_mode_cfg$spe_lighten_ratio`** — `ratio`
- **`PeripheralLightApp$blt_cus_mode_get`** — `mode`
- **`PeripheralLightApp$blt_cus_mode_modify`** — `cycle`, `mode`, `ratio`, `subtype`, `value`
- **`PeripheralLightApp$blt_cus_mode_modify$blt_light_value`** — `lightNum`, `pct`
- **`PeripheralLightApp$blt_cus_mode_modify$filcker_cycle`** — `cycle`
- **`PeripheralLightApp$blt_cus_mode_modify$lighten_ratio`** — `ratio`
- **`PeripheralLightApp$blt_left_time`** — `time`
- **`PeripheralLightApp$blt_light_mode_cur`** — `curMode`
- **`PeripheralLightApp$blt_light_self`** — `lightCnt`, `lightType`
- **`PeripheralLightApp$blt_message_format`** — `batPct`, `bltOperateType`, `bltServiceType`, `cfgSet`, `cfgSup`, `curMode`, `cusModeGet`, `customCfg`, `leftTime`, `lightSelf`, `modeArg`, `modeSet`, `modeSup`, `operateType`, `rideCfgAll`, `rideCfgSet`, `serviceType`
- **`PeripheralLightApp$blt_mode_enable`** — `enable`, `mode`
- **`PeripheralLightApp$blt_mode_sup`** — `editable`, `enable`, `mode`, `modeType`
- **`PeripheralLightApp$blt_mode_sup$blt_mode_editable`** — `isEditable`
- **`PeripheralLightApp$blt_smt_cfg`** — `config`, `status`, `userData`
- **`PeripheralLightApp$blt_smt_cfg$cfg_user_data`** — `data`
- **`PeripheralLightApp$blt_spe_lightness`** — `lightNum`, `pct`
- **`PeripheralLightApp$ride_cfg_msg`** — `brakeCfg`, `config`, `status`
- **`PeripheralLightApp$ride_cfg_msg$brake_cfg_msg`** — `flash`, `index`, `intensity`, `intensityLevel`
- **`PeripheralLightApp$ride_cfg_msg$brake_cfg_msg$intensity_level_msg`** — `level`
- **`PeripheralLightApp$ride_cfg_msg_all`** — `rideCfg`
- **`PeripheralOem$peripheral_oem_data_ble`** — `name`
- **`PeripheralOem$peripheral_oem_data_device`** — `id`, `model`, `name`
- **`PeripheralOem$peripheral_oem_data_manufacturer`** — `id`, `name`
- **`PeripheralOem$peripheral_oem_format`** — `message`, `operateType`, `serviceType`, `subOperateType`, `subServiceType`
- **`PeripheralOem$peripheral_oem_message`** — `bleInfo`, `deviceInfo`, `manufacturerInfo`
- **`PeripheralRadar$peripheral_acc_message`** — `x`, `y`, `z`
- **`PeripheralRadar$peripheral_radar_format`** — `meaagse`, `operateType`, `serviceType`, `subOperateType`, `subServiceType`
- **`PeripheralRadar$peripheral_radar_message`** — `accInfo`, `radarInfo`
- **`PeripheralRadar$peripheral_radar_target_message`** — `level`, `range`, `speed`
- **`RealTimeTrace$real_time_trace_fit_message`** — `bitField0`, `fitContent`, `timestamp`
- **`RealTimeTrace$real_time_trace_msg`** — `bitField0`, `realTimeTraceFitMsg`, `realTimeTraceOperateType`, `serviceType`
- **`RouteBook$route_book_data_msg`** — `bitField0`, `operateType`, `routeBookInforMsg`, `routeBookListGetMsg`, `serviceType`, `subOperateType`
- **`RouteBook$route_book_infor_message`** — `bitField0`, `id`, `name`, `status`
- **`RoutePlan$app_support_function_status`** — `bitField0`, `isSupportReroute`
- **`RoutePlan$reroute_point_info_message`** — `bitField0`, `rerouteEndPoint`, `reroutePassPoint`, `rerouteStartPoint`
- **`RoutePlan$route_plan_data_msg`** — `bitField0`, `fileContent`, `lineId`, `reroutePointMsg`, `rerouteStatus`, `routeListGetMsg`, `routePlanInfoMsg`, `routePlanOperateType`, `serviceType`, `supportFunctionStatus`
- **`RoutePlan$route_plan_info_message`** — `bitField0`, `fileType`, `id`, `latitudeStart`, `longitudeStart`, `name`, `status`, `totalDistance`
- **`RoutePlan$route_point_msg`** — `bitField0`, `latitude`, `longitude`
- **`Sensor$di2_sensor_set_message`** — `bitField0`, `buttonOpType`, `func`, `num`
- **`Sensor$radar_sensor_set_message`** — `alertBarSide`, `alertSoundOpen`, `bitField0`
- **`Sensor$sensor_data_message`** — `autoWheelSize`, `bitField0`, `crankLength`, `di2SensorSetMsg`, `radarSensorSetMsg`, `sensorBleName`, `sensorForbidden`, `sensorKey`, `sensorPwr`, `sensorRadioType`, `sensorRssi`, `sensorStatusType`, `sensorType`, `wheelSize`
- **`Sensor$sensor_message`** — `bitField0`, `sensorDataMsg`, `sensorOperateType`, `serviceType`
- **`SportAbility$sport_ability_msg`** — `bitField0`, `serviceType`, `sportAbilityOperateType`, `sportAbilitySyncDataMsg`
- **`SportAbility$sport_ability_sync_data_message`** — `bitField0`, `endTimestamp`, `startTimestamp`
- **`SportPageField$sport_page_field_msg`** — `bitField0`, `serviceType`, `sportPageFieldOperateType`
- **`Stage$stage_data_msg`** — `bitField0`, `listMsg`, `serviceType`, `stageFileMsg`, `statgeDateOperateType`
- **`Stage$stage_file_message`** — `bitField0`, `fileId`, `fileName`, `fileSize`
- **`TeamInfo$team_info_data_msg`** — `bitField0`, `course`, `latitude`, `longitude`, `nickName`, `status`
- **`TeamInfo$team_info_msg`** — `bitField0`, `memberNum`, `serviceType`, `teamInfoDataMessage`, `teamInfoOperateType`
- **`Theme$theme_func_info`** — `bitField0`, `funcKey`, `isClosable`, `isRemovable`, `open`, `themeUiHeight`, `themeUiWidth`, `ui`
- **`Theme$theme_infor_msg`** — `bitField0`, `funcInfo`, `funcKey`, `funcKey_converter`, `themeColor`, `themeId`, `themeIndex`, `themeStatus`, `themeUitype`
- **`Theme$theme_message`** — `bgType`, `bitField0`, `darkMode`, `isDefaultBg`, `opCode`, `serviceType`, `themeInfo`
- **`Theme$ui_dimension`** — `bitField0`, `themeUiHeight`, `themeUiWidth`
- **`TrainPlan$schedule_data_msg`** — `bitField0`, `fileNumber`, `operateType`, `scheduleDateOperateType`, `scheduleName`, `serviceType`, `utcTime`
- **`Training$training_data_message`** — `bitField0`, `fileContent`, `fileId`, `fileName`, `fileType`, `trainingObjectMessage`, `trainingPeriod`, `trainingTime`, `trainingType`
- **`Training$training_list_message`** — `bitField0`, `fileId`, `fileName`, `fileType`, `status`, `trainingPeriod`
- **`Training$training_message`** — `bitField0`, `moduleInfoMsg`, `operateType`, `serviceType`, `trainingDataMsg`, `trainingListGetMsg`, `trainingListMsg`, `trainingSubOperateType`
- **`Training$training_module_info_message`** — `bitField0`, `subOperateType`, `subOperateType_converter`, `trainingModuleVersion`
- **`Training$training_object_msg`** — `bitField0`, `dataMax`, `dataMin`, `trainningObj`
- **`UserConfig$user_config_data_msg`** — `age`, `bikeWeight`, `bitField0`, `height`, `memberId`, `sex`, `timeZone`, `weight`, `wheelDia`
- **`UserConfig$user_config_msg`** — `bitField0`, `serviceType`, `userConfigDataMessage`, `userConfigOperateType`
- **`WatchConfig$watch_alarm_msg`** — `alarmIntervalTime`, `bitField0`, `setMsg`
- **`WatchConfig$watch_alarm_params_set_msg`** — `alarmType`, `bitField0`, `selectInfo`, `status`, `valueMax`, `valueMaxEn`, `valueMin`, `valueMinEn`
- **`WatchConfig$watch_alarm_select_info`** — `alarmSelect`, `bitField0`, `status`, `value`
- **`WatchConfig$watch_auto_set_msg`** — `autoType`, `bitField0`, `mode`, `param1`, `status`
- **`WatchConfig$watch_backlight_msg`** — `backlightAuto`, `backlightDayPercent`, `backlightNightOn`, `backlightNightPercent`, `backlingTime`, `bitField0`
- **`WatchConfig$watch_config_msg`** — `alarmMessage`, `autoSetMessage`, `backlightMessage`, `bitField0`, `configOperateType`, `configServiceType`, `curOperateMode`, `languageMessage`, `menuListMessage`, `pageMessage`, `pageStatusMessage`, `serviceType`, `timeSystemType`, `unitMessage`, `userData`
- **`WatchConfig$watch_cur_page_status_msg`** — `bitField0`, `dataPageNumMax`, `mainPageOpen`, `pageLineDataMax`, `pageLineNumMax`, `supportPageLayout`, `unsupportData`
- **`WatchConfig$watch_language_msg`** — `bitField0`, `curLanguage`, `supportedLanguage`, `supportedLanguage_converter`
- **`WatchConfig$watch_layout_mode_msg`** — `bitField0`, `dataCount`, `style`
- **`WatchConfig$watch_menu_item_msg`** — `appType`, `bitField0`, `consoleType`, `sportType`, `state`
- **`WatchConfig$watch_menu_list_msg`** — `bitField0`, `menuItem`, `menuType`, `minDisplayCount`
- **`WatchConfig$watch_page_msg`** — `bitField0`, `data`, `forbiddenClose`, `homePage`, `layoutMode`, `pageIndex`, `pageName`, `pageType`, `status`
- **`WatchConfig$watch_section_data_msg`** — `bitField0`, `cad`, `fTP`, `power`, `rideHrType`, `rideHrm`, `rideLacticAcidHrm`, `rideReserveHr`, `runHrType`, `runHrm`, `runLacticAcidHrm`, `runReserveHr`, `spd`, `swimHrType`, `swimHrm`, `swimLacticAcidHrm`, `swimReserveHr`
- **`WatchConfig$watch_unit_msg`** — `bitField0`, `unitItem`, `unitType`
- **`WatchConfig$watch_user_data_msg`** — `birthday`, `bitField0`, `height`, `hrRest`, `rideHrLacticAcid`, `rideHrMax`, `runHrLacticAcid`, `runHrMax`, `sectionData`, `sex`, `stepLength`, `swimHrLacticAcid`, `swimHrMax`, `timestamp`, `updateStatus`, `wearHand`, `weight`
- **`WatchDial$dial_msg`** — `bitField0`, `cfgMessage`, `dialInfoMessage`, `fileList`, `fileListGet`, `operationType`, `serviceType`, `state`
- **`WatchDial$watch_dial_base_info_message`** — `bitField0`, `masterDialInfo`, `maxDialNum`, `resolutionHeight`, `resolutionWidth`
- **`WatchDial$watch_dial_cfg_message`** — `bitField0`, `colorCurType`, `colorSupportType`, `colorSupportType_converter`, `dataCurType`, `dataCurType_converter`, `dataSupportType`, `dataSupportType_converter`, `dialType`, `goodsid`
- **`WatchDial$watch_dial_file_flag_message`** — `bitField0`, `dialType`, `fileSize`, `goodsid`, `inUse`
- **`WatchDial$watch_master_dial_message`** — `allowTimePositionType`, `allowTimePositionType_converter`
- **`WatchHealthData$watch_daily_alarm_message`** — `alarmInterval`, `alarmSwitch`, `alarmTimeEnd`, `alarmTimeStart`, `bitField0`, `dailyAlarmType`, `dndEnd`, `dndStart`, `dndSwitch`
- **`WatchHealthData$watch_daily_target_message`** — `bitField0`, `dailyActivityType`, `goalValue`, `status`
- **`WatchHealthData$watch_health_data_file_list_message`** — `bitField0`, `fileName`, `healthDataType`
- **`WatchHealthData$watch_health_data_message`** — `bitField0`, `calories`, `healthDataType`, `healthDataValue`, `hrvPeriodMsg`, `intenseTime`, `sleepDataMsg`, `step`, `timestamp`, `timezone`
- **`WatchHealthData$watch_health_msg`** — `bitField0`, `dailyAlarmMsg`, `dailyTargetMsg`, `fileListMsg`, `fileListNum`, `healthDataMsg`, `healthDataOperateType`, `serviceType`, `version`, `watchDailyAllAlarmStatus`
- **`WatchHealthData$watch_hrv_period_message`** — `avg`, `bitField0`, `dataNum`, `hrvData`, `max`, `min`, `reserved`, `sum`, `timestamp`, `timezone`
- **`WatchHealthData$watch_short_sleep_data_message`** — `bitField0`, `endTime`, `startTime`, `totalTime`
- **`WatchHealthData$watch_short_sleep_period_message`** — `bitField0`, `dataNum`, `shortSleepDataMsg`
- **`WatchHealthData$watch_sleep_data_message`** — `bitField0`, `shortSleepPeriodMsg`, `sleepPeriodStageMsg`, `sleepPeriodSummaryMsg`, `timestamp`
- **`WatchHealthData$watch_sleep_period_stage_message`** — `bitField0`, `num`, `sleepStageMsg`
- **`WatchHealthData$watch_sleep_period_summary_message`** — `bitField0`, `deepMinutes`, `endTime`, `lightMinutes`, `remMinutes`, `sleepScore`, `sleepType`, `stageNum`, `startTime`, `totalTime`, `wakeMinutes`
- **`WatchHealthData$watch_sleep_stage_message`** — `bitField0`, `stage`, `totalTime`
- **`Wifi$wifi_data_message`** — `bitField0`, `encryptionType`, `hidessid`, `key`, `openStatus`, `signalStrength`, `ssid`, `status`
- **`Wifi$wifi_msg`** — `bitField0`, `cpuUuid`, `serviceType`, `wifiDataMsg`, `wifiOperateType`, `wifiQuickUpgradeMsg`, `wifiSyncStates`, `wifiUrlMsg`
- **`Wifi$wifi_quick_upgrade_message`** — `bitField0`, `firmwareMd5`, `firmwareVersion`
- **`Wifi$wifi_sync_message`** — `bitField0`, `syncType`
- **`Wifi$wifi_url_message`** — `acceptLanguage`, `baseUrl`, `bitField0`, `encryptedMemberId`, `memberId`, `summaryListUrl`, `timezone`
- **`DeviceConstant`** — `iGS320`
