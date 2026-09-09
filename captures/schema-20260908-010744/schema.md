# Schéma protobuf — `com.qiwu.worldwide.ride-8.06.42-base.apk`

> Extrait le 08/09/2026 à 01:07 par `tools/dump-proto-schema.py`.
> Filtre : `com/igpsport/blelib`. Messages décodés : 263.

> Un message marqué ⚠️ n'a pas passé la validation : ne pas s'y fier sans vérification.

### `AlgGmData$pb_gm_format_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `operateType` |

### `AlgGmData$pb_gm_historical_data`

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:sfixed32` | `records` |

### `AlgGmData$pb_gm_historical_record` ⚠️

- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 148 hors bornes [1, 7]
- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `fTP` |
| **4** | `oneof:enum` | `trainingLoad` |
| **139** | `double` | `timestamp` |
| **139** | `uint64` | `trainingStatus` |
| **148** | `oneof:sint64` | `mAP` |
| **225** | `oneof:bool` | `vO2Max` |

### `AlgGmData$pb_gm_persistent_data` ⚠️

- ⚠️ champ 137 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **137** | `double` | `statistical` |

### `AlgGmData$pb_gm_statistical_outputs` ⚠️

- ⚠️ champ 139 hors bornes [1, 20]
- ⚠️ champ 225 hors bornes [1, 20]
- ⚠️ champ 148 hors bornes [1, 20]
- ⚠️ champ 139 hors bornes [1, 20]
- ⚠️ champ 225 hors bornes [1, 20]
- ⚠️ champ 148 hors bornes [1, 20]
- ⚠️ champ 139 hors bornes [1, 20]
- ⚠️ champ 225 hors bornes [1, 20]
- ⚠️ champ 148 hors bornes [1, 20]
- ⚠️ champ 139 hors bornes [1, 20]
- ⚠️ champ 225 hors bornes [1, 20]
- ⚠️ champ 148 hors bornes [1, 20]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `recoveryTime` |
| **4** | `fixed32` | `aerobicAbiltiy` |
| **4** | `oneof:enum` | `powerAbility` |
| **7** | `message` | `pWR` |
| **7** | `oneof:enum` | `ultraEnduranceAbility` |
| **10** | `enum` | `trainingStatus` |
| **10** | `oneof:enum` | `trainingLoad` |
| **139** | `double` | `startTime` |
| **139** | `fixed32` | `vO2Max` |
| **139** | `message` | `lTHR` |
| **139** | `uint64` | `anaerobicAbility` |
| **148** | `oneof:message` | `staminaLevel` |
| **148** | `oneof:sint64` | `enduranceAbiltiy` |
| **148** | `oneof:sint64` | `mAP` |
| **148** | `oneof:sint64` | `tlTrend` |
| **225** | `oneof:bool` | `aerobicPowerAbility` |
| **225** | `oneof:bool` | `endTime` |
| **225** | `oneof:bool` | `fTP` |
| **225** | `oneof:bool` | `pHRZ` |

### `AppWatch$watch_control_format` ⚠️

- ⚠️ champ 140 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `operateType` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `subServiceType` |

### `AppWatch$watch_device_info_message` ⚠️

- ⚠️ champ 136 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **136** | `double` | `deviceName` |

### `Back$air_pressure_data_message` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `Back$back_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 10]
- ⚠️ champ 225 hors bornes [1, 10]
- ⚠️ champ 148 hors bornes [1, 10]
- ⚠️ champ 137 hors bornes [1, 10]
- ⚠️ champ 27 hors bornes [1, 10]
- ⚠️ champ 128 hors bornes [1, 10]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `backOperateType` |
| **4** | `repeated message` | `curMsg` |
| **5** | `oneof:enum` | `threeHoursMsg` |
| **27** | `bool` | `ephemerisDataMsg` |
| **128** | `oneof:sfixed64` | `timeMsg` |
| **137** | `uint64` | `airPressureMsg` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:group` | `threeDaysMsg` |
| **225** | `oneof:bool` | `backServiceType` |

### `Back$ephemeris_data_message` ⚠️

- ⚠️ champ 136 hors bornes [1, 5]
- ⚠️ champ 225 hors bornes [1, 5]
- ⚠️ champ 128 hors bornes [1, 5]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `gpsType` |
| **128** | `oneof:group` | `agpsType` |
| **136** | `double` | `fileName` |
| **225** | `oneof:fixed64` | `contents` |

### `Back$locate_info_data_message` ⚠️

- ⚠️ champ 128 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **128** | `double` | `latitude` |

### `Back$time_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `time` |
| **225** | `oneof:fixed64` | `timeZone` |

### `Back$weather_current_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 11]
- ⚠️ champ 225 hors bornes [1, 11]
- ⚠️ champ 128 hors bornes [1, 11]
- ⚠️ champ 132 hors bornes [1, 11]
- ⚠️ champ 225 hors bornes [1, 11]
- ⚠️ champ 128 hors bornes [1, 11]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `curDayMaxTemp` |
| **4** | `fixed32` | `humidity` |
| **4** | `oneof:enum` | `time` |
| **128** | `oneof:message` | `curDayMinTemp` |
| **128** | `oneof:sfixed32` | `airQuality` |
| **132** | `uint64` | `windDeg` |
| **139** | `double` | `curTemperature` |
| **225** | `oneof:fixed64` | `curWeather` |
| **225** | `oneof:fixed64` | `windSpd` |

### `Back$weather_three_days_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `minTemp` |
| **4** | `oneof:enum` | `date` |
| **128** | `oneof:message` | `rainProb` |
| **139** | `double` | `weatherIndex` |
| **139** | `uint64` | `sunRiseTime` |
| **225** | `oneof:fixed64` | `maxTemp` |

### `Back$weather_three_hour_data_memsage` ⚠️

- ⚠️ champ 139 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `rainProb` |
| **4** | `oneof:enum` | `windDeg` |
| **128** | `oneof:sint64` | `time` |
| **139** | `double` | `watherIndex` |
| **225** | `oneof:fixed64` | `temp` |

### `Ble$ble_bond_status_message` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `Ble$ble_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `status` |

### `Ble$ble_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 5]
- ⚠️ champ 225 hors bornes [1, 5]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `bleDataMsg` |
| **4** | `oneof:enum` | `bleBondUserMsg` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `bleOperateType` |

### `Ble$watch_ble_bond_user_message` ⚠️

- ⚠️ champ 136 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `bondAllow` |
| **136** | `double` | `userId` |
| **225** | `oneof:fixed64` | `state` |

### `CloudSwitchDev$cloud_switch_dev_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `serviceType` |

### `Common$file_list_get_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 5]
- ⚠️ champ 225 hors bornes [1, 5]
- ⚠️ champ 128 hors bornes [1, 5]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `fileIndexStart` |
| **128** | `oneof:sint64` | `fileIndexEnd` |
| **139** | `double` | `fileNum` |
| **225** | `oneof:fixed64` | `fileListSupportNumMax` |

### `Config$accident_detection_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `accidentDetectionOpen` |

### `Config$alarm_msg` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:sfixed32` | `bitField0` |
| **2** | `oneof:enum` | `setMsg` |

### `Config$alarm_params_set_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `valueMin` |
| **4** | `oneof:enum` | `selectType` |
| **128** | `oneof:sint64` | `status` |
| **140** | `double` | `alarmType` |
| **225** | `oneof:fixed64` | `valueMax` |

### `Config$alarm_select_info` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `selectType` |

### `Config$auto_set_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `autoType` |
| **225** | `oneof:fixed64` | `status` |

### `Config$backlight_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 5]
- ⚠️ champ 225 hors bornes [1, 5]
- ⚠️ champ 128 hors bornes [1, 5]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `backlightAuto` |
| **128** | `oneof:sint64` | `backlightDayPercent` |
| **139** | `double` | `backlightNightOn` |
| **225** | `oneof:fixed64` | `backlingTime` |

### `Config$bike_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `bikeWeigth` |
| **4** | `oneof:enum` | `odometer` |
| **128** | `oneof:sint64` | `wheelDia` |
| **139** | `double` | `bikeIndex` |
| **139** | `uint64` | `autoDia` |
| **225** | `oneof:fixed64` | `bikeName` |

### `Config$config_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 30]
- ⚠️ champ 225 hors bornes [1, 30]
- ⚠️ champ 148 hors bornes [1, 30]
- ⚠️ champ 137 hors bornes [1, 30]
- ⚠️ champ 137 hors bornes [1, 30]
- ⚠️ champ 225 hors bornes [1, 30]
- ⚠️ champ 144 hors bornes [1, 30]
- ⚠️ champ 137 hors bornes [1, 30]
- ⚠️ champ 225 hors bornes [1, 30]
- ⚠️ champ 208 hors bornes [1, 30]
- ⚠️ champ 208 hors bornes [1, 30]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `configOperateType` |
| **4** | `oneof:enum` | `pageMessage` |
| **5** | `enum` | `curOperateMode` |
| **7** | `repeated message` | `pageStatusMessage` |
| **8** | `oneof:enum` | `altitude` |
| **8** | `repeated int64` | `keySetMessage` |
| **13** | `oneof:enum` | `alarmMessage` |
| **27** | `fixed32` | `unitMessage` |
| **27** | `repeated bool` | `passwordMessage` |
| **27** | `repeated fixed32` | `timeSystem` |
| **27** | `repeated uint64` | `soundSetMessage` |
| **137** | `bool` | `lapMessage` |
| **137** | `int32` | `languageMessage` |
| **137** | `uint64` | `bikeMessage` |
| **140** | `double` | `serviceType` |
| **144** | `oneof:sfixed64` | `modeMessage` |
| **148** | `oneof:group` | `userDataMessage` |
| **208** | `oneof:sfixed64` | `dataMessage` |
| **208** | `oneof:sfixed64` | `modeConfigMessage` |
| **225** | `oneof:bool` | `configSeviceType` |
| **225** | `oneof:fixed64` | `autoSetMessage` |
| **225** | `oneof:fixed64` | `backlightMessage` |

### `Config$cur_page_status_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 11]
- ⚠️ champ 225 hors bornes [1, 11]
- ⚠️ champ 128 hors bornes [1, 11]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `dataPageNumMax` |
| **4** | `repeated uint32` | `lcdType` |
| **5** | `oneof:enum` | `supportPageLayout` |
| **128** | `oneof:sint64` | `unsupportData` |
| **139** | `double` | `pageLineNumMax` |
| **225** | `oneof:fixed64` | `pageLineDataMax` |

### `Config$data_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `dataType` |

### `Config$emergency_contact_msg` ⚠️

- ⚠️ champ 136 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `areaCode` |
| **136** | `double` | `name` |
| **225** | `oneof:fixed64` | `phone` |

### `Config$key_set_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `keyType` |
| **225** | `oneof:fixed64` | `keyFunctionType` |

### `Config$language_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `curLanguage` |

### `Config$lap_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `lapType` |
| **225** | `oneof:fixed64` | `value` |

### `Config$mode_config_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `defaultModeNum` |

### `Config$mode_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `valid` |
| **4** | `oneof:enum` | `templateIndex` |
| **128** | `oneof:sint64` | `inuse` |
| **139** | `double` | `modeIndex` |
| **225** | `oneof:fixed64` | `modeColor` |

### `Config$page_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 11]
- ⚠️ champ 225 hors bornes [1, 11]
- ⚠️ champ 139 hors bornes [1, 11]
- ⚠️ champ 225 hors bornes [1, 11]
- ⚠️ champ 128 hors bornes [1, 11]
- ⚠️ champ 139 hors bornes [1, 11]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `data` |
| **3** | `fixed32` | `pageMode` |
| **4** | `oneof:enum` | `dataSite` |
| **7** | `oneof:enum` | `lineWidth` |
| **128** | `oneof:group` | `mainPageStatus` |
| **139** | `double` | `pageIndex` |
| **139** | `fixed64` | `graphicDisplay` |
| **139** | `int64` | `pageName` |
| **225** | `oneof:fixed64` | `pageType` |
| **225** | `oneof:fixed64` | `status` |

### `Config$password_msg` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `Config$section_data_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 23]
- ⚠️ champ 29 hors bornes [1, 23]
- ⚠️ champ 29 hors bornes [1, 23]
- ⚠️ champ 29 hors bornes [1, 23]
- ⚠️ champ 29 hors bornes [1, 23]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `repeated uint32` | `bitField0` |
| **2** | `repeated uint32` | `hrm` |
| **3** | `repeated uint32` | `cad` |
| **10** | `oneof:enum` | `spd` |
| **29** | `repeated fixed64` | `rideReserveHr` |
| **29** | `repeated int32` | `rideLacticAcidHrm` |
| **29** | `repeated int64` | `power` |
| **29** | `repeated uint64` | `rideHrm` |
| **139** | `double` | `fTP` |

### `Config$sound_set_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `soundType` |
| **225** | `oneof:fixed64` | `soundScene` |

### `Config$unit_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `unitItem` |

### `Config$user_data_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 22]
- ⚠️ champ 225 hors bornes [1, 22]
- ⚠️ champ 128 hors bornes [1, 22]
- ⚠️ champ 139 hors bornes [1, 22]
- ⚠️ champ 225 hors bornes [1, 22]
- ⚠️ champ 128 hors bornes [1, 22]
- ⚠️ champ 139 hors bornes [1, 22]
- ⚠️ champ 225 hors bornes [1, 22]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `age` |
| **4** | `oneof:enum` | `timeZone` |
| **4** | `string` | `rideHrMax` |
| **9** | `oneof:enum` | `restHr` |
| **128** | `oneof:sfixed32` | `rideHrLacticAcid` |
| **128** | `oneof:sint64` | `height` |
| **139** | `double` | `sex` |
| **139** | `fixed32` | `sectionData` |
| **139** | `uint64` | `memberId` |
| **225** | `oneof:fixed64` | `personalInforChangeTime` |
| **225** | `oneof:fixed64` | `updateStatus` |
| **225** | `oneof:fixed64` | `weight` |

### `CyclingData$cycling_data_auto_upload_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `status` |
| **225** | `oneof:fixed64` | `cyclingDataUrl` |

### `CyclingData$cycling_data_file_flag_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `userId` |
| **139** | `double` | `timestamp` |
| **225** | `oneof:fixed64` | `fileSize` |

### `CyclingData$cycling_data_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 155 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `cyclingDataFileFlagMsg` |
| **128** | `oneof:sint32` | `cyclingDataAutoUploadMsg` |
| **140** | `double` | `serviceType` |
| **155** | `int32` | `fileContent` |
| **225** | `oneof:bool` | `cyclingDataOperateType` |

### `DevStatus$dev_cycling_status_massage` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `devCyclingStatus` |

### `DevStatus$dev_gps_massage` ⚠️

- ⚠️ champ 128 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **128** | `double` | `latitude` |

### `DevStatus$dev_position_point` ⚠️

- ⚠️ champ 132 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `pointname` |
| **132** | `double` | `latitude` |
| **225** | `oneof:fixed64` | `longitude` |

### `DevStatus$dev_position_point_group` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `positionPointNum` |

### `DevStatus$dev_status_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ champ 128 hors bornes [1, 8]
- ⚠️ champ 137 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `devCyclingStatusMsg` |
| **4** | `oneof:enum` | `rtDataMsg` |
| **128** | `oneof:sfixed64` | `devGpsMsg` |
| **137** | `uint64` | `wifiStatus` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `opType` |
| **225** | `oneof:fixed64` | `naviStatus` |

### `DevStatus$rt_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 19]
- ⚠️ champ 225 hors bornes [1, 19]
- ⚠️ champ 128 hors bornes [1, 19]
- ⚠️ champ 139 hors bornes [1, 19]
- ⚠️ champ 225 hors bornes [1, 19]
- ⚠️ champ 128 hors bornes [1, 19]
- ⚠️ champ 139 hors bornes [1, 19]
- ⚠️ champ 225 hors bornes [1, 19]
- ⚠️ champ 128 hors bornes [1, 19]
- ⚠️ champ 132 hors bornes [1, 19]
- ⚠️ champ 225 hors bornes [1, 19]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `ridingTime` |
| **4** | `fixed32` | `realTimePower` |
| **4** | `oneof:enum` | `realTimeCad` |
| **7** | `message` | `maxSpeed` |
| **7** | `oneof:enum` | `avgRise` |
| **10** | `enum` | `maxPower` |
| **10** | `oneof:enum` | `avgCad` |
| **128** | `oneof:message` | `maxHrm` |
| **128** | `oneof:sint64` | `ridingDistance` |
| **128** | `oneof:sint64` | `totalHeight` |
| **132** | `message` | `maxCad` |
| **139** | `double` | `realTimeSpeed` |
| **139** | `fixed32` | `curHeight` |
| **139** | `uint64` | `realTimeHrm` |
| **225** | `oneof:fixed64` | `avgHrm` |
| **225** | `oneof:fixed64` | `avgPower` |
| **225** | `oneof:fixed64` | `avgSpeed` |
| **225** | `oneof:fixed64` | `curSlope` |

### `DevVerInfo$dev_ver_info_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `operateType` |

### `DevVerInfo$version_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `bleBootVer` |
| **4** | `oneof:enum` | `hardwareVer` |
| **128** | `oneof:sint64` | `bleAppVer` |
| **139** | `double` | `mainBootVer` |
| **139** | `uint64` | `protocolVer` |
| **225** | `oneof:fixed64` | `mainAppVer` |

### `DeviceInformation$DeviceImage`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `imageType` |
| **2** | `oneof:fixed64` | `url` |

### `DeviceInformation$DeviceInfo`

| # | Type | Champ |
|---|---|---|
| **1** | `repeated message` | `deviceImage` |
| **2** | `oneof:fixed64` | `devName` |
| **3** | `oneof:fixed64` | `devCustomName` |
| **4** | `int32` | `generation` |
| **5** | `bool` | `isSupportProtoBuf` |
| **6** | `int32` | `sendFileMtuSize` |
| **7** | `int32` | `dataReceiveTimeOut` |
| **8** | `repeated message [packed]` | `functionTypeList` |
| **9** | `oneof:fixed64` | `manufacturerSpecificData` |
| **10** | `repeated message` | `mapManual` |
| **11** | `repeated message` | `pagingInformation` |
| **12** | `bool` | `isAccessory` |
| **13** | `int32` | `ephemerisEffectiveTime` |
| **14** | `int32` | `deviceMaxActivityFileNum` |
| **15** | `int32` | `connectionMode` |
| **16** | `int32` | `androidSupportMinVersion` |
| **17** | `int32` | `upperLimitOfMode` |
| **18** | `bool` | `isShowRecommendDevice` |
| **19** | `enum` | `deviceCategoryType` |
| **20** | `bool` | `isSupportAuth` |
| **21** | `enum` | `pairMode` |

### `DeviceInformation$MapManual`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `manualType` |
| **2** | `oneof:fixed64` | `url` |

### `DeviceInformation$PagingInformation`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `function` |
| **2** | `bool` | `isSupportPaging` |

### `EmojiLight$emoji_base_msg`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `rawSize` |
| **2** | `uint32` | `colSize` |
| **3** | `uint32` | `batPct` |
| **4** | `uint32` | `version` |
| **5** | `uint32` | `curEmoji` |
| **6** | `uint32` | `emojiCnt` |
| **7** | `repeated message` | `savedMsg` |
| **8** | `uint32` | `maxEmojiCnt` |

### `EmojiLight$emoji_delete_msg`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `uid` |

### `EmojiLight$emoji_detail_msg`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `uid` |
| **2** | `enum` | `attr` |
| **3** | `uint32` | `intensity` |
| **4** | `message` | `modeIndex` |
| **5** | `oneof:fixed64` | `emojiName` |
| **6** | `uint32` | `isGlobalIntensity` |

### `EmojiLight$emoji_index_msg`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `emojiMode` |

### `EmojiLight$emoji_msg_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `emojiService` |
| **4** | `enum` | `emojiOperate` |
| **5** | `message` | `msgAll` |

### `EmojiLight$emoji_msgs_all`

| # | Type | Champ |
|---|---|---|
| **1** | `message` | `baseMsg` |
| **2** | `message` | `detail` |
| **3** | `message` | `delete` |
| **4** | `message` | `single` |
| **5** | `message` | `myAbbrEmoji` |

### `EmojiLight$my_emoji_abbr_msg`

| # | Type | Champ |
|---|---|---|
| **1** | `repeated message` | `savedMsg` |
| **2** | `uint32` | `uidInUsing` |

### `EmojiLight$single_emoji_pb_stream_msg`

| # | Type | Champ |
|---|---|---|
| **1** | `bytes` | `pbData` |
| **2** | `uint32` | `size` |

### `Factory$ant_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `devType` |
| **225** | `oneof:fixed64` | `devConnectStatus` |

### `Factory$battary_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `voltage` |

### `Factory$control_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `cmdType` |

### `Factory$data_set_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `dataType` |

### `Factory$factory_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 20]
- ⚠️ champ 225 hors bornes [1, 20]
- ⚠️ champ 137 hors bornes [1, 20]
- ⚠️ champ 225 hors bornes [1, 20]
- ⚠️ champ 128 hors bornes [1, 20]
- ⚠️ champ 137 hors bornes [1, 20]
- ⚠️ champ 225 hors bornes [1, 20]
- ⚠️ champ 128 hors bornes [1, 20]
- ⚠️ champ 137 hors bornes [1, 20]
- ⚠️ champ 225 hors bornes [1, 20]
- ⚠️ champ 128 hors bornes [1, 20]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `factorySnMsg` |
| **3** | `bool` | `controlMsg` |
| **4** | `repeated message` | `factorySensorMsg` |
| **5** | `oneof:enum` | `memoryMsg` |
| **6** | `bytes` | `filterMsg` |
| **8** | `oneof:enum` | `sunTimeMsg` |
| **9** | `sfixed32` | `dataSetMsg` |
| **11** | `oneof:enum` | `gpsGnssMsg` |
| **128** | `oneof:sfixed64` | `gpsControlCmdMsg` |
| **128** | `oneof:sfixed64` | `gpsCoordinateMsg` |
| **128** | `oneof:sfixed64` | `gpsSnrMsg` |
| **137** | `fixed64` | `powerSaveMsg` |
| **137** | `int64` | `battaryMsg` |
| **137** | `string` | `gpsDynamicMsg` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `factoryOperateType` |
| **225** | `oneof:fixed64` | `gpsCmdMsg` |
| **225** | `oneof:fixed64` | `rtcMsg` |
| **225** | `oneof:fixed64` | `simFitMsg` |

### `Factory$factory_sensor_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `sensorType` |
| **225** | `oneof:fixed64` | `data` |

### `Factory$factory_sn_message` ⚠️

- ⚠️ champ 136 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **136** | `double` | `sn` |

### `Factory$filter_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `filterType` |

### `Factory$gps_cmd_message`

| # | Type | Champ |
|---|---|---|
| **1** | `repeated bytes` | `gpsCmd` |

### `Factory$gps_control_cmd_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `gpsCmdType` |

### `Factory$gps_coordinate_message` ⚠️

- ⚠️ champ 128 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **128** | `double` | `latitude` |

### `Factory$gps_dynamic_message` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `Factory$gps_gnss_message` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `Factory$gps_snr_massage` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `gnssType` |

### `Factory$memory_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `total` |

### `Factory$power_save_message` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `Factory$rtc_message` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `Factory$sim_fit_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `num` |

### `Factory$sun_time_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `sunriseTime` |

### `FileDownload$file_download` ⚠️

- ⚠️ champ 139 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ champ 128 hors bornes [1, 8]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `fileId` |
| **4** | `oneof:enum` | `fileVerifyVal` |
| **128** | `oneof:sint64` | `fileName` |
| **139** | `double` | `fileSize` |
| **225** | `oneof:fixed64` | `fileType` |

### `Firmware$firmware_auto_download_status_message` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `Firmware$firmware_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ champ 136 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `firmwareSize` |
| **4** | `oneof:enum` | `process` |
| **128** | `oneof:sint64` | `url` |
| **136** | `uint64` | `bleBootFirmwareVer` |
| **139** | `double` | `mcuFirmwareVer` |
| **225** | `oneof:fixed64` | `bleFirmwareVer` |

### `Firmware$firmware_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `firmwareDataMsg` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `firmwareOperateType` |

### `GeneralFileOperation$file_extra_Info` ⚠️

- ⚠️ champ 132 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `avgSlope` |
| **4** | `oneof:enum` | `routePackName` |
| **128** | `oneof:message` | `routePackId` |
| **132** | `double` | `distance` |
| **225** | `oneof:fixed64` | `totalAscent` |

### `GeneralFileOperation$file_transfer_method_information` ⚠️

- ⚠️ champ 135 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **135** | `double` | `resumeSupported` |
| **225** | `oneof:fixed64` | `packetAckSupported` |

### `GeneralFileOperation$general_file_operation` ⚠️

- ⚠️ champ 140 hors bornes [1, 15]
- ⚠️ champ 225 hors bornes [1, 15]
- ⚠️ champ 148 hors bornes [1, 15]
- ⚠️ champ 139 hors bornes [1, 15]
- ⚠️ champ 225 hors bornes [1, 15]
- ⚠️ champ 128 hors bornes [1, 15]
- ⚠️ champ 136 hors bornes [1, 15]
- ⚠️ champ 225 hors bornes [1, 15]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `fileType` |
| **4** | `fixed32` | `fileMd5` |
| **4** | `oneof:enum` | `fileId` |
| **7** | `oneof:enum` | `isTemp` |
| **128** | `oneof:sfixed32` | `fileVerifyVal` |
| **136** | `fixed32` | `extraInfo` |
| **139** | `uint64` | `fileName` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:group` | `fileSize` |
| **225** | `oneof:bool` | `fileExtension` |
| **225** | `oneof:bool` | `operateType` |
| **225** | `oneof:fixed64` | `watchPhotoDialExtraInfo` |

### `GeneralFileOperation$watch_photo_dial_extra_Info` ⚠️

- ⚠️ champ 139 hors bornes [1, 5]
- ⚠️ champ 225 hors bornes [1, 5]
- ⚠️ champ 128 hors bornes [1, 5]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `color` |
| **128** | `oneof:sint64` | `num` |
| **139** | `double` | `dialId` |
| **225** | `oneof:fixed64` | `timePositionType` |

### `GroupRide$group_ride_ctrl_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `reason` |
| **139** | `double` | `groupRideId` |
| **225** | `oneof:fixed64` | `status` |

### `GroupRide$group_ride_infor_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `latitude` |
| **4** | `oneof:enum` | `strightLineDistance` |
| **128** | `oneof:fixed64` | `longitude` |
| **139** | `double` | `memberId` |
| **225** | `oneof:fixed64` | `status` |

### `GroupRide$group_ride_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 148 hors bornes [1, 7]
- ⚠️ champ 137 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `msgType` |
| **4** | `oneof:enum` | `personalInfor` |
| **137** | `uint64` | `rideInfor` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:group` | `onlineStatus` |
| **225** | `oneof:bool` | `operateType` |

### `GroupRide$online_status_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `status` |

### `GroupRide$personal_infor_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `nikename` |
| **139** | `double` | `memberId` |
| **225** | `oneof:bool` | `memberIdentity` |

### `Ins$ancs_filter_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `catagoryId` |
| **225** | `oneof:fixed64` | `appIdentifier` |

### `Ins$ins_data_message` ⚠️

- ⚠️ champ 138 hors bornes [1, 10]
- ⚠️ champ 225 hors bornes [1, 10]
- ⚠️ champ 128 hors bornes [1, 10]
- ⚠️ champ 136 hors bornes [1, 10]
- ⚠️ champ 225 hors bornes [1, 10]
- ⚠️ champ 128 hors bornes [1, 10]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `content` |
| **4** | `fixed32` | `isApp` |
| **4** | `oneof:enum` | `uid` |
| **128** | `oneof:sfixed32` | `time` |
| **128** | `oneof:sint64` | `pairingCode` |
| **136** | `uint64` | `count` |
| **138** | `double` | `telNum` |
| **225** | `oneof:fixed64` | `appName` |
| **225** | `oneof:fixed64` | `name` |

### `Ins$ins_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 148 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `insOperateType` |
| **4** | `oneof:enum` | `config` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:group` | `insDataMsg` |
| **225** | `oneof:bool` | `insServiceType` |

### `LanguagePack$language_pack_info_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `fontType` |
| **4** | `oneof:enum` | `packSize` |
| **128** | `oneof:group` | `fontSize` |
| **139** | `uint64` | `url` |
| **140** | `double` | `languageType` |
| **225** | `oneof:fixed64` | `languageVersin` |

### `LanguagePack$language_pack_module_info_msg` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `repeated enum` | `bitField0` |
| **2** | `oneof:enum` | `supportCmd` |

### `LanguagePack$language_pack_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 16]
- ⚠️ champ 225 hors bornes [1, 16]
- ⚠️ champ 148 hors bornes [1, 16]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `languageSubOperate` |
| **4** | `oneof:sfixed32` | `content` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:group` | `languagePackInfoMessage` |
| **225** | `oneof:bool` | `operateType` |

### `Log$log_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 148 hors bornes [1, 7]
- ⚠️ champ 136 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `subOperate` |
| **4** | `oneof:enum` | `content` |
| **136** | `uint64` | `logNum` |
| **140** | `double` | `service` |
| **148** | `oneof:group` | `logName` |
| **225** | `oneof:bool` | `operate` |

### `Map$map_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ champ 128 hors bornes [1, 8]
- ⚠️ champ 136 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `version` |
| **4** | `oneof:enum` | `size` |
| **128** | `oneof:sint64` | `url` |
| **136** | `uint64` | `areaType` |
| **139** | `double` | `mapId` |
| **225** | `oneof:fixed64` | `areaId` |
| **225** | `oneof:fixed64` | `progress` |

### `Map$map_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `mapOperateType` |

### `Media$media_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `playerMsg` |
| **4** | `oneof:enum` | `trackMsg` |
| **128** | `oneof:sfixed64` | `queueMsg` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `operateType` |

### `Media$player_message` ⚠️

- ⚠️ champ 136 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `playerRate` |
| **4** | `oneof:enum` | `volumeMax` |
| **128** | `oneof:sint64` | `elapsedTime` |
| **136** | `double` | `playerName` |
| **225** | `oneof:fixed64` | `playerState` |

### `Media$queue_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `queueIndex` |
| **225** | `oneof:fixed64` | `queueCount` |

### `Media$track_message` ⚠️

- ⚠️ champ 136 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `title` |
| **136** | `double` | `artist` |
| **225** | `oneof:fixed64` | `album` |

### `PeripheralConfig$peripheral_config_data_broadcast`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `dataSwitch` |

### `PeripheralConfig$peripheral_config_data_shutdown`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `shutdownSwitch` |
| **2** | `uint32` | `countdown` |

### `PeripheralConfig$peripheral_config_data_sleep`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `sleepSwitch` |
| **2** | `uint32` | `countdown` |

### `PeripheralConfig$peripheral_config_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `subServiceType` |
| **4** | `enum` | `subOperateType` |
| **5** | `message` | `message` |

### `PeripheralConfig$peripheral_config_light_mode`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `lightMode` |

### `PeripheralConfig$peripheral_config_message`

| # | Type | Champ |
|---|---|---|
| **1** | `message` | `shutdown` |
| **2** | `message` | `sleep` |
| **3** | `message` | `light` |
| **4** | `message` | `dataService` |

### `PeripheralFactory$peripheral_factory_data_ant_id`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `antId` |

### `PeripheralFactory$peripheral_factory_data_bsp_acc`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `xAxisVal` |
| **2** | `int32` | `yAxisVal` |
| **3** | `int32` | `zAxisVal` |

### `PeripheralFactory$peripheral_factory_data_bsp_battery`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `volCur` |
| **2** | `uint32` | `percent` |

### `PeripheralFactory$peripheral_factory_data_bsp_lsr`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `lightness` |

### `PeripheralFactory$peripheral_factory_data_bsp_memory`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `remainInternalFlash` |
| **2** | `uint32` | `totalInternalFlash` |
| **3** | `uint32` | `remainIexternalFlash` |
| **4** | `uint32` | `totalExternalFlash` |

### `PeripheralFactory$peripheral_factory_data_bsp_radar_raw`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `amplitude` |
| **2** | `uint32` | `frequency` |

### `PeripheralFactory$peripheral_factory_data_bsp_radar_test`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `radarTestCmd` |
| **2** | `repeated message` | `radarTestData` |

### `PeripheralFactory$peripheral_factory_data_bsp_rtc`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `zone` |
| **2** | `uint32` | `rtc` |
| **3** | `uint32` | `sunrise` |
| **4** | `uint32` | `sunset` |

### `PeripheralFactory$peripheral_factory_data_bsp_temperature`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `tempCur` |
| **2** | `int32` | `tempMax` |

### `PeripheralFactory$peripheral_factory_data_capacitance`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `capacitance` |
| **2** | `int32` | `capacitanceCollect` |
| **3** | `int32` | `capacitanceReference` |
| **4** | `int32` | `diffCollect` |
| **5** | `int32` | `diffReference` |

### `PeripheralFactory$peripheral_factory_data_device_config`

| # | Type | Champ |
|---|---|---|
| **1** | `message` | `shutdown` |
| **2** | `message` | `sleep` |

### `PeripheralFactory$peripheral_factory_data_device_info`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `model` |
| **2** | `message` | `name` |
| **3** | `message` | `version` |
| **4** | `message` | `id` |

### `PeripheralFactory$peripheral_factory_data_device_operate`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `hrSportMode` |

### `PeripheralFactory$peripheral_factory_data_fcal_result`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `result` |

### `PeripheralFactory$peripheral_factory_data_ppg_test_data`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `state` |
| **2** | `enum` | `testType` |
| **3** | `uint32` | `firstErrorCode` |
| **4** | `uint32` | `firstFailedChannel` |
| **6** | `repeated message` | `ctrValues` |
| **7** | `repeated message` | `noiseValues` |
| **8** | `repeated message` | `baseNoiseValues` |
| **9** | `repeated message` | `dcOffsetValues` |
| **10** | `repeated message` | `snrValues` |
| **11** | `repeated message` | `llpctrValues` |
| **12** | `repeated message` | `leakRatioValues` |

### `PeripheralFactory$peripheral_factory_data_radar_snr`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `snr` |
| **2** | `uint32` | `signal` |
| **3** | `uint32` | `noise` |

### `PeripheralFactory$peripheral_factory_data_sn`

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:fixed64` | `sn` |

### `PeripheralFactory$peripheral_factory_data_therm_vol`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `vol` |

### `PeripheralFactory$peripheral_factory_data_void_welding`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `f7RegAddr` |
| **2** | `uint32` | `channel1` |
| **3** | `uint32` | `channel2` |
| **4** | `uint32` | `channel3` |
| **5** | `uint32` | `channel4` |
| **6** | `uint32` | `lockState` |
| **7** | `uint32` | `lockVal` |
| **8** | `uint32` | `anaVal` |

### `PeripheralFactory$peripheral_factory_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `subServiceType` |
| **4** | `enum` | `subOperateType` |
| **5** | `message` | `message` |

### `PeripheralFactory$peripheral_factory_message`

| # | Type | Champ |
|---|---|---|
| **1** | `message` | `sn` |
| **2** | `message` | `deviceInfo` |
| **3** | `message` | `deviceOperate` |
| **4** | `message` | `deviceConfig` |
| **5** | `message` | `bspMemory` |
| **6** | `message` | `bspRtc` |
| **7** | `message` | `bspBattery` |
| **8** | `message` | `bspTemperature` |
| **9** | `message` | `bspAcc` |
| **10** | `message` | `radarTest` |
| **11** | `message` | `bspLsr` |
| **12** | `message` | `thermVol` |
| **13** | `message` | `ant` |
| **14** | `message` | `voidWelding` |
| **15** | `message` | `otaData` |
| **16** | `message` | `fcalResult` |
| **17** | `message` | `selfTest` |
| **18** | `message` | `capacitance` |
| **19** | `message` | `ppgTestData` |

### `PeripheralFactory$peripheral_self_test_result`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `result` |

### `PeripheralFactory$ppg_channel_value`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `channelIdx` |
| **2** | `int32` | `value` |

### `PeripheralFirmware$peripheral_firmware_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `subServiceType` |
| **4** | `enum` | `subOperateType` |
| **5** | `message` | `message` |

### `PeripheralFirmware$peripheral_firmware_message`

| # | Type | Champ |
|---|---|---|
| **6** | `uint32` | `binPacketSize` |
| **7** | `bytes` | `binPacketData` |
| **8** | `uint32` | `binTotalSize` |

### `PeripheralHr$peripheral_hr_data_sport_mode`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `keySwitch` |
| **2** | `enum` | `mode` |

### `PeripheralHr$peripheral_hr_data_warn`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `warnSwitch` |
| **2** | `bool` | `highSwitch` |
| **3** | `bool` | `lowSwitch` |
| **4** | `enum` | `highWarnType` |
| **5** | `enum` | `lowWarnType` |
| **6** | `int64` | `highValue` |
| **7** | `int64` | `lowValue` |

### `PeripheralHr$peripheral_hr_data_zone`

| # | Type | Champ |
|---|---|---|
| **1** | `repeated int64 [packed]` | `value` |

### `PeripheralHr$peripheral_hr_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `subServiceType` |
| **4** | `enum` | `subOperateType` |
| **5** | `message` | `message` |

### `PeripheralHr$peripheral_hr_message`

| # | Type | Champ |
|---|---|---|
| **6** | `message` | `hrmWarn` |
| **11** | `message` | `hrZone` |
| **16** | `message` | `sportMode` |

### `PeripheralInfo$peripheral_info_data_id`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `deviceId` |
| **2** | `uint32` | `manufacturerId` |

### `PeripheralInfo$peripheral_info_data_memory`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `remainInternalFlash` |
| **2** | `uint32` | `totalInternalFlash` |
| **3** | `uint32` | `remainIexternalFlash` |
| **4** | `uint32` | `totalExternalFlash` |
| **5** | `uint32` | `remainInternalRam` |
| **6** | `uint32` | `totalInternalRam` |
| **7** | `uint32` | `remainExternalRam` |
| **8** | `uint32` | `totalExternalRam` |

### `PeripheralInfo$peripheral_info_data_name`

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:fixed64` | `deviceName` |
| **2** | `oneof:fixed64` | `bleName` |
| **3** | `oneof:fixed64` | `manufacturerName` |

### `PeripheralInfo$peripheral_info_data_power`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `volCur` |
| **2** | `uint32` | `percent` |

### `PeripheralInfo$peripheral_info_data_temperature`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `tempCur` |
| **2** | `int32` | `tempMax` |

### `PeripheralInfo$peripheral_info_data_version`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `mcuVersion` |
| **2** | `uint32` | `appVersion` |
| **3** | `uint32` | `bootVersion` |
| **4** | `uint32` | `hardVersion` |
| **5** | `uint32` | `checkVersion` |
| **6** | `bool` | `supportCommonMcuUpgrade` |

### `PeripheralInfo$peripheral_info_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `subServiceType` |
| **4** | `enum` | `subOperateType` |
| **5** | `message` | `message` |

### `PeripheralInfo$peripheral_info_message`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `model` |
| **2** | `message` | `name` |
| **3** | `message` | `version` |
| **11** | `message` | `id` |
| **16** | `message` | `power` |
| **17** | `message` | `temperature` |
| **18** | `message` | `memory` |

### `PeripheralLight$auto_low_cfg`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `status` |
| **2** | `int32` | `timeOut` |

### `PeripheralLight$auto_pwr_cfg`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `status` |

### `PeripheralLight$custome_mode_config`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `mode` |
| **2** | `int32` | `mLightness` |
| **3** | `int32` | `pLightness` |
| **4** | `int32` | `cycle` |
| **5** | `int32` | `ratio` |

### `PeripheralLight$peripheral_auto_config_message`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `autoLight` |
| **2** | `bool` | `brakeSwtich` |
| **3** | `bool` | `teamRide` |
| **4** | `enum` | `autoSleep` |
| **5** | `int32` | `sleepCnt` |
| **6** | `bool` | `syncOff` |
| **7** | `message` | `autoPwr` |
| **8** | `message` | `autoLow` |

### `PeripheralLight$peripheral_light_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `subServiceType` |
| **4** | `enum` | `subOperateType` |
| **5** | `message` | `message` |

### `PeripheralLight$peripheral_light_message`

| # | Type | Champ |
|---|---|---|
| **1** | `repeated message [packed]` | `lightModesSupport` |
| **2** | `enum` | `curMode` |
| **3** | `enum` | `cusMode` |
| **4** | `message` | `cusConfig` |
| **5** | `message` | `autoConfig` |
| **6** | `enum` | `sleepFlag` |
| **7** | `enum` | `autolightFlag` |
| **8** | `int32` | `remainTime` |
| **9** | `enum` | `offFlag` |
| **10** | `enum` | `lightType` |
| **11** | `repeated message [packed]` | `lightCfgSup` |

### `PeripheralLightApp$blt_bat_pct`

| # | Type | Champ |
|---|---|---|
| **13** | `int32` | `batPct` |

### `PeripheralLightApp$blt_cus_mode_arg`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `mode` |
| **2** | `enum` | `selected` |
| **3** | `repeated message` | `cusMode` |

### `PeripheralLightApp$blt_cus_mode_cfg`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `subtype` |
| **2** | `repeated message` | `lightnessMap` |
| **3** | `message` | `speCycle` |
| **4** | `message` | `speRatio` |

### `PeripheralLightApp$blt_cus_mode_cfg$spe_flicker_cycle`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `cycle` |

### `PeripheralLightApp$blt_cus_mode_cfg$spe_lighten_ratio`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `ratio` |

### `PeripheralLightApp$blt_cus_mode_get`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `mode` |

### `PeripheralLightApp$blt_cus_mode_modify`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `mode` |
| **2** | `enum` | `subtype` |
| **3** | `message` | `value` |
| **4** | `message` | `cycle` |
| **5** | `message` | `ratio` |

### `PeripheralLightApp$blt_cus_mode_modify$blt_light_value`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `lightNum` |
| **2** | `int32` | `pct` |

### `PeripheralLightApp$blt_cus_mode_modify$filcker_cycle`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `cycle` |

### `PeripheralLightApp$blt_cus_mode_modify$lighten_ratio`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `ratio` |

### `PeripheralLightApp$blt_left_time`

| # | Type | Champ |
|---|---|---|
| **1** | `int64` | `time` |

### `PeripheralLightApp$blt_light_mode_cur`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `curMode` |

### `PeripheralLightApp$blt_light_self`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `lightType` |
| **2** | `int32` | `lightCnt` |

### `PeripheralLightApp$blt_message_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `bltServiceType` |
| **4** | `enum` | `bltOperateType` |
| **5** | `message` | `lightSelf` |
| **6** | `repeated message` | `modeSup` |
| **7** | `message` | `cusModeGet` |
| **8** | `message` | `modeArg` |
| **9** | `repeated message` | `cfgSup` |
| **10** | `message` | `cfgSet` |
| **11** | `message` | `modeSet` |
| **12** | `message` | `customCfg` |
| **13** | `message` | `curMode` |
| **14** | `message` | `leftTime` |
| **15** | `message` | `batPct` |
| **16** | `message` | `rideCfgAll` |
| **17** | `message` | `rideCfgSet` |

### `PeripheralLightApp$blt_mode_enable`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `mode` |
| **2** | `bool` | `enable` |

### `PeripheralLightApp$blt_mode_sup`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `mode` |
| **2** | `enum` | `modeType` |
| **3** | `bool` | `enable` |
| **4** | `message` | `editable` |

### `PeripheralLightApp$blt_mode_sup$blt_mode_editable`

| # | Type | Champ |
|---|---|---|
| **1** | `bool` | `isEditable` |

### `PeripheralLightApp$blt_smt_cfg`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `config` |
| **2** | `enum` | `status` |
| **3** | `message` | `userData` |

### `PeripheralLightApp$blt_smt_cfg$cfg_user_data`

| # | Type | Champ |
|---|---|---|
| **1** | `int64` | `data` |

### `PeripheralLightApp$blt_spe_lightness`

| # | Type | Champ |
|---|---|---|
| **1** | `int32` | `lightNum` |
| **2** | `int32` | `pct` |

### `PeripheralLightApp$ride_cfg_msg`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `config` |
| **2** | `enum` | `status` |
| **3** | `message` | `brakeCfg` |

### `PeripheralLightApp$ride_cfg_msg$brake_cfg_msg`

| # | Type | Champ |
|---|---|---|
| **1** | `uint32` | `index` |
| **2** | `bool` | `flash` |
| **3** | `uint32` | `intensity` |
| **4** | `message` | `intensityLevel` |

### `PeripheralLightApp$ride_cfg_msg$brake_cfg_msg$intensity_level_msg`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `level` |

### `PeripheralLightApp$ride_cfg_msg_all`

| # | Type | Champ |
|---|---|---|
| **1** | `repeated message` | `rideCfg` |

### `PeripheralOem$peripheral_oem_data_ble`

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:fixed64` | `name` |

### `PeripheralOem$peripheral_oem_data_device`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `model` |
| **2** | `oneof:fixed64` | `name` |
| **3** | `uint32` | `id` |

### `PeripheralOem$peripheral_oem_data_manufacturer`

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:fixed64` | `name` |
| **2** | `uint32` | `id` |

### `PeripheralOem$peripheral_oem_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `subServiceType` |
| **4** | `enum` | `subOperateType` |
| **5** | `message` | `message` |

### `PeripheralOem$peripheral_oem_message`

| # | Type | Champ |
|---|---|---|
| **1** | `message` | `bleInfo` |
| **2** | `message` | `deviceInfo` |
| **3** | `message` | `manufacturerInfo` |

### `PeripheralRadar$peripheral_acc_message`

| # | Type | Champ |
|---|---|---|
| **6** | `int32` | `x` |
| **7** | `int32` | `y` |
| **8** | `int32` | `z` |

### `PeripheralRadar$peripheral_radar_format`

| # | Type | Champ |
|---|---|---|
| **1** | `enum` | `serviceType` |
| **2** | `enum` | `operateType` |
| **3** | `enum` | `subServiceType` |
| **4** | `enum` | `subOperateType` |
| **5** | `message` | `meaagse` |

### `PeripheralRadar$peripheral_radar_message`

| # | Type | Champ |
|---|---|---|
| **6** | `repeated message` | `radarInfo` |
| **7** | `repeated message` | `accInfo` |

### `PeripheralRadar$peripheral_radar_target_message`

| # | Type | Champ |
|---|---|---|
| **6** | `int32` | `level` |
| **7** | `int32` | `range` |
| **8** | `int32` | `speed` |

### `RealTimeTrace$real_time_trace_fit_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `timestamp` |

### `RealTimeTrace$real_time_trace_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `realTimeTraceOperateType` |

### `RouteBook$route_book_data_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 10]
- ⚠️ champ 225 hors bornes [1, 10]
- ⚠️ champ 148 hors bornes [1, 10]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `subOperateType` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:group` | `routeBookInforMsg` |
| **225** | `oneof:bool` | `operateType` |

### `RouteBook$route_book_infor_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `id` |
| **225** | `oneof:fixed64` | `name` |

### `RoutePlan$app_support_function_status` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `RoutePlan$reroute_point_info_message` ⚠️

- ⚠️ champ 137 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **137** | `double` | `rerouteStartPoint` |
| **225** | `oneof:bool` | `rerouteEndPoint` |

### `RoutePlan$route_plan_data_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 12]
- ⚠️ champ 225 hors bornes [1, 12]
- ⚠️ champ 138 hors bornes [1, 12]
- ⚠️ champ 27 hors bornes [1, 12]
- ⚠️ champ 144 hors bornes [1, 12]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `lineId` |
| **4** | `oneof:enum` | `fileContent` |
| **7** | `oneof:enum` | `supportFunctionStatus` |
| **27** | `fixed32` | `reroutePointMsg` |
| **138** | `int64` | `routePlanInfoMsg` |
| **140** | `double` | `serviceType` |
| **144** | `oneof:sfixed64` | `rerouteStatus` |
| **225** | `oneof:bool` | `routePlanOperateType` |

### `RoutePlan$route_plan_info_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `name` |
| **4** | `oneof:enum` | `longitudeStart` |
| **128** | `oneof:sfixed32` | `totalDistance` |
| **139** | `double` | `id` |
| **139** | `uint64` | `latitudeStart` |
| **225** | `oneof:fixed64` | `fileType` |

### `RoutePlan$route_point_msg` ⚠️

- ⚠️ champ 128 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **128** | `double` | `longitude` |

### `Sensor$di2_sensor_set_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `num` |
| **225** | `oneof:fixed64` | `buttonOpType` |

### `Sensor$radar_sensor_set_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `alertBarSide` |

### `Sensor$sensor_data_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 13]
- ⚠️ champ 225 hors bornes [1, 13]
- ⚠️ champ 128 hors bornes [1, 13]
- ⚠️ champ 136 hors bornes [1, 13]
- ⚠️ champ 225 hors bornes [1, 13]
- ⚠️ champ 128 hors bornes [1, 13]
- ⚠️ champ 139 hors bornes [1, 13]
- ⚠️ champ 225 hors bornes [1, 13]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `sensorStatusType` |
| **4** | `fixed32` | `wheelSize` |
| **4** | `oneof:enum` | `sensorBleName` |
| **7** | `oneof:enum` | `sensorForbidden` |
| **128** | `oneof:group` | `sensorKey` |
| **128** | `oneof:message` | `crankLength` |
| **136** | `uint64` | `sensorRssi` |
| **139** | `fixed32` | `autoWheelSize` |
| **140** | `double` | `sensorType` |
| **225** | `oneof:fixed64` | `radarSensorSetMsg` |
| **225** | `oneof:fixed64` | `sensorPwr` |
| **225** | `oneof:fixed64` | `sensorRadioType` |

### `Sensor$sensor_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `sensorOperateType` |

### `SportAbility$sport_ability_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `sportAbilityOperateType` |

### `SportAbility$sport_ability_sync_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `startTimestamp` |

### `SportPageField$sport_page_field_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `serviceType` |

### `Stage$stage_data_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `stageFileMsg` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `statgeDateOperateType` |

### `Stage$stage_file_message` ⚠️

- ⚠️ champ 136 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **136** | `double` | `fileName` |
| **225** | `oneof:fixed64` | `fileSize` |

### `TeamInfo$team_info_data_msg` ⚠️

- ⚠️ champ 128 hors bornes [1, 5]
- ⚠️ champ 225 hors bornes [1, 5]
- ⚠️ champ 128 hors bornes [1, 5]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `status` |
| **128** | `double` | `latitude` |
| **128** | `oneof:sint64` | `nickName` |
| **225** | `oneof:fixed64` | `longitude` |

### `TeamInfo$team_info_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `memberNum` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `teamInfoOperateType` |

### `Theme$theme_func_info` ⚠️

- ⚠️ champ 140 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ champ 140 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `themeUiWidth` |
| **4** | `oneof:enum` | `isRemovable` |
| **128** | `oneof:group` | `themeUiHeight` |
| **140** | `double` | `funcKey` |
| **140** | `uint64` | `isClosable` |
| **225** | `oneof:fixed64` | `open` |

### `Theme$theme_infor_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `themeStatus` |
| **4** | `repeated enum` | `themeUitype` |
| **5** | `oneof:enum` | `themeColor` |
| **128** | `oneof:group` | `funcKey` |
| **139** | `double` | `themeId` |
| **225** | `oneof:fixed64` | `themeIndex` |

### `Theme$theme_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 155 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `themeInfo` |
| **128** | `oneof:group` | `bgType` |
| **140** | `double` | `serviceType` |
| **155** | `int32` | `darkMode` |
| **225** | `oneof:bool` | `opCode` |

### `Theme$ui_dimension` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `themeUiWidth` |

### `TrainPlan$schedule_data_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 148 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `operateType` |
| **4** | `oneof:enum` | `utcTime` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:group` | `fileNumber` |
| **225** | `oneof:bool` | `scheduleDateOperateType` |

### `Training$training_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 13]
- ⚠️ champ 225 hors bornes [1, 13]
- ⚠️ champ 128 hors bornes [1, 13]
- ⚠️ champ 139 hors bornes [1, 13]
- ⚠️ champ 225 hors bornes [1, 13]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `fileType` |
| **4** | `oneof:enum` | `trainingType` |
| **128** | `oneof:group` | `trainingPeriod` |
| **139** | `double` | `fileId` |
| **139** | `uint64` | `trainingObjectMessage` |
| **225** | `oneof:fixed64` | `fileName` |
| **225** | `oneof:fixed64` | `trainingTime` |

### `Training$training_list_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 5]
- ⚠️ champ 225 hors bornes [1, 5]
- ⚠️ champ 128 hors bornes [1, 5]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `fileName` |
| **128** | `oneof:sfixed32` | `status` |
| **139** | `double` | `fileId` |
| **225** | `oneof:fixed64` | `fileType` |

### `Training$training_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 13]
- ⚠️ champ 225 hors bornes [1, 13]
- ⚠️ champ 148 hors bornes [1, 13]
- ⚠️ champ 137 hors bornes [1, 13]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `trainingSubOperateType` |
| **4** | `oneof:enum` | `trainingListGetMsg` |
| **137** | `uint64` | `trainingListMsg` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:group` | `trainingDataMsg` |
| **225** | `oneof:bool` | `operateType` |

### `Training$training_module_info_message` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `repeated enum` | `bitField0` |
| **2** | `oneof:enum` | `subOperateType` |

### `Training$training_object_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `trainningObj` |
| **225** | `oneof:fixed64` | `dataMax` |

### `UserConfig$user_config_data_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ champ 128 hors bornes [1, 8]
- ⚠️ champ 139 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `age` |
| **4** | `oneof:enum` | `wheelDia` |
| **128** | `oneof:sint64` | `height` |
| **139** | `double` | `sex` |
| **139** | `uint64` | `bikeWeight` |
| **225** | `oneof:fixed64` | `timeZone` |
| **225** | `oneof:fixed64` | `weight` |

### `UserConfig$user_config_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `userConfigOperateType` |

### `WatchConfig$watch_alarm_msg` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:sfixed32` | `bitField0` |
| **2** | `oneof:enum` | `setMsg` |

### `WatchConfig$watch_alarm_params_set_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ champ 128 hors bornes [1, 8]
- ⚠️ champ 139 hors bornes [1, 8]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `valueMin` |
| **4** | `oneof:enum` | `selectInfo` |
| **128** | `oneof:sint64` | `status` |
| **139** | `uint64` | `valueMaxEn` |
| **140** | `double` | `alarmType` |
| **225** | `oneof:fixed64` | `valueMax` |

### `WatchConfig$watch_alarm_select_info` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `alarmSelect` |
| **225** | `oneof:fixed64` | `value` |

### `WatchConfig$watch_auto_set_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `param1` |
| **140** | `double` | `autoType` |
| **225** | `oneof:fixed64` | `status` |

### `WatchConfig$watch_backlight_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 5]
- ⚠️ champ 225 hors bornes [1, 5]
- ⚠️ champ 128 hors bornes [1, 5]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `backlightAuto` |
| **128** | `oneof:sint64` | `backlightDayPercent` |
| **139** | `double` | `backlightNightOn` |
| **225** | `oneof:fixed64` | `backlingTime` |

### `WatchConfig$watch_config_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 25]
- ⚠️ champ 225 hors bornes [1, 25]
- ⚠️ champ 148 hors bornes [1, 25]
- ⚠️ champ 137 hors bornes [1, 25]
- ⚠️ champ 208 hors bornes [1, 25]
- ⚠️ champ 27 hors bornes [1, 25]
- ⚠️ champ 128 hors bornes [1, 25]
- ⚠️ champ 137 hors bornes [1, 25]
- ⚠️ champ 225 hors bornes [1, 25]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `configOperateType` |
| **4** | `oneof:enum` | `pageMessage` |
| **6** | `repeated float` | `menuListMessage` |
| **12** | `oneof:enum` | `curOperateMode` |
| **27** | `string` | `languageMessage` |
| **128** | `oneof:sfixed64` | `backlightMessage` |
| **137** | `fixed64` | `alarmMessage` |
| **137** | `uint64` | `unitMessage` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:group` | `userData` |
| **208** | `oneof:sfixed64` | `pageStatusMessage` |
| **225** | `oneof:bool` | `configServiceType` |
| **225** | `oneof:fixed64` | `autoSetMessage` |

### `WatchConfig$watch_cur_page_status_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 11]
- ⚠️ champ 225 hors bornes [1, 11]
- ⚠️ champ 128 hors bornes [1, 11]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `dataPageNumMax` |
| **4** | `repeated uint32` | `supportPageLayout` |
| **128** | `oneof:sint64` | `unsupportData` |
| **139** | `double` | `pageLineNumMax` |
| **225** | `oneof:fixed64` | `pageLineDataMax` |

### `WatchConfig$watch_language_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `curLanguage` |

### `WatchConfig$watch_layout_mode_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `dataCount` |

### `WatchConfig$watch_menu_item_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `consoleType` |
| **140** | `double` | `appType` |
| **225** | `oneof:fixed64` | `sportType` |

### `WatchConfig$watch_menu_list_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 27 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **27** | `uint64` | `menuItem` |
| **140** | `double` | `menuType` |

### `WatchConfig$watch_page_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ champ 128 hors bornes [1, 8]
- ⚠️ champ 140 hors bornes [1, 8]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `layoutMode` |
| **4** | `repeated uint32` | `pageType` |
| **5** | `oneof:enum` | `forbiddenClose` |
| **128** | `oneof:sfixed64` | `data` |
| **139** | `double` | `pageIndex` |
| **140** | `uint64` | `homePage` |
| **225** | `oneof:fixed64` | `status` |

### `WatchConfig$watch_section_data_msg` ⚠️

- ⚠️ champ 139 hors bornes [1, 22]
- ⚠️ champ 29 hors bornes [1, 22]
- ⚠️ champ 140 hors bornes [1, 22]
- ⚠️ champ 225 hors bornes [1, 22]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `repeated uint32` | `bitField0` |
| **2** | `repeated uint32` | `runHrm` |
| **3** | `repeated uint32` | `cad` |
| **4** | `repeated uint32` | `spd` |
| **5** | `repeated uint32` | `rideHrm` |
| **10** | `oneof:enum` | `swimHrm` |
| **15** | `repeated uint32` | `runLacticAcidHrm` |
| **16** | `repeated uint32` | `rideLacticAcidHrm` |
| **17** | `repeated uint32` | `swimLacticAcidHrm` |
| **18** | `repeated uint32` | `runReserveHr` |
| **19** | `repeated uint32` | `rideReserveHr` |
| **20** | `oneof:enum` | `swimReserveHr` |
| **29** | `sfixed64` | `power` |
| **139** | `double` | `fTP` |
| **140** | `float` | `runHrType` |
| **225** | `oneof:fixed64` | `rideHrType` |

### `WatchConfig$watch_unit_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `unitItem` |

### `WatchConfig$watch_user_data_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 21]
- ⚠️ champ 225 hors bornes [1, 21]
- ⚠️ champ 128 hors bornes [1, 21]
- ⚠️ champ 139 hors bornes [1, 21]
- ⚠️ champ 225 hors bornes [1, 21]
- ⚠️ champ 128 hors bornes [1, 21]
- ⚠️ champ 139 hors bornes [1, 21]
- ⚠️ champ 225 hors bornes [1, 21]
- ⚠️ champ 128 hors bornes [1, 21]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `height` |
| **4** | `fixed32` | `runHrLacticAcid` |
| **4** | `oneof:enum` | `stepLength` |
| **7** | `bytes` | `swimHrLacticAcid` |
| **7** | `oneof:enum` | `rideHrMax` |
| **11** | `oneof:enum` | `sectionData` |
| **128** | `oneof:group` | `timestamp` |
| **128** | `oneof:sint64` | `wearHand` |
| **128** | `oneof:sint64` | `weight` |
| **139** | `fixed32` | `swimHrMax` |
| **139** | `uint64` | `runHrMax` |
| **140** | `double` | `sex` |
| **225** | `oneof:fixed64` | `birthday` |
| **225** | `oneof:fixed64` | `hrRest` |
| **225** | `oneof:fixed64` | `rideHrLacticAcid` |

### `WatchDial$dial_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `fileListGet` |
| **4** | `repeated message` | `cfgMessage` |
| **5** | `oneof:enum` | `dialInfoMessage` |
| **128** | `oneof:sfixed64` | `fileList` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `operationType` |

### `WatchDial$watch_dial_base_info_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `masterDialInfo` |
| **139** | `double` | `resolutionWidth` |
| **225** | `oneof:fixed64` | `resolutionHeight` |

### `WatchDial$watch_dial_cfg_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 6]
- ⚠️ champ 30 hors bornes [1, 6]
- ⚠️ champ 140 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **4** | `repeated enum` | `dataCurType` |
| **5** | `oneof:enum` | `colorSupportType` |
| **30** | `uint64` | `dataSupportType` |
| **139** | `double` | `goodsid` |
| **140** | `float` | `colorCurType` |

### `WatchDial$watch_dial_file_flag_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `inUse` |
| **139** | `double` | `goodsid` |
| **225** | `oneof:fixed64` | `fileSize` |

### `WatchDial$watch_master_dial_message`

| # | Type | Champ |
|---|---|---|
| **1** | `repeated enum` | `allowTimePositionType` |

### `WatchHealthData$watch_daily_alarm_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ champ 128 hors bornes [1, 8]
- ⚠️ champ 139 hors bornes [1, 8]
- ⚠️ champ 225 hors bornes [1, 8]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `alarmTimeStart` |
| **4** | `oneof:enum` | `alarmInterval` |
| **128** | `oneof:sint64` | `alarmTimeEnd` |
| **139** | `uint64` | `dndStart` |
| **140** | `double` | `dailyAlarmType` |
| **225** | `oneof:fixed64` | `alarmSwitch` |
| **225** | `oneof:fixed64` | `dndEnd` |

### `WatchHealthData$watch_daily_target_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **140** | `double` | `dailyActivityType` |
| **225** | `oneof:fixed64` | `goalValue` |

### `WatchHealthData$watch_health_data_file_list_message` ⚠️

- ⚠️ champ 136 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **136** | `double` | `fileName` |

### `WatchHealthData$watch_health_data_message` ⚠️

- ⚠️ champ 140 hors bornes [1, 9]
- ⚠️ champ 225 hors bornes [1, 9]
- ⚠️ champ 128 hors bornes [1, 9]
- ⚠️ champ 139 hors bornes [1, 9]
- ⚠️ champ 225 hors bornes [1, 9]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `timezone` |
| **4** | `fixed32` | `calories` |
| **4** | `oneof:enum` | `sleepDataMsg` |
| **128** | `oneof:message` | `healthDataValue` |
| **139** | `uint64` | `hrvPeriodMsg` |
| **140** | `double` | `healthDataType` |
| **225** | `oneof:fixed64` | `step` |
| **225** | `oneof:fixed64` | `timestamp` |

### `WatchHealthData$watch_health_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 9]
- ⚠️ champ 225 hors bornes [1, 9]
- ⚠️ champ 148 hors bornes [1, 9]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `version` |
| **4** | `oneof:sfixed32` | `dailyTargetMsg` |
| **5** | `oneof:sfixed32` | `dailyAlarmMsg` |
| **6** | `oneof:sfixed32` | `fileListNum` |
| **7** | `oneof:enum` | `watchDailyAllAlarmStatus` |
| **140** | `double` | `serviceType` |
| **148** | `oneof:sint64` | `healthDataMsg` |
| **225** | `oneof:bool` | `healthDataOperateType` |

### `WatchHealthData$watch_hrv_period_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 9]
- ⚠️ champ 225 hors bornes [1, 9]
- ⚠️ champ 128 hors bornes [1, 9]
- ⚠️ champ 139 hors bornes [1, 9]
- ⚠️ champ 29 hors bornes [1, 9]
- ⚠️ champ 128 hors bornes [1, 9]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `sum` |
| **4** | `oneof:enum` | `hrvData` |
| **29** | `fixed32` | `max` |
| **128** | `oneof:sint64` | `avg` |
| **128** | `oneof:sint64` | `dataNum` |
| **139** | `double` | `timestamp` |
| **139** | `uint64` | `min` |
| **225** | `oneof:fixed64` | `timezone` |

### `WatchHealthData$watch_short_sleep_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 3]
- ⚠️ champ 225 hors bornes [1, 3]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `startTime` |
| **225** | `oneof:fixed64` | `endTime` |

### `WatchHealthData$watch_short_sleep_period_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `dataNum` |

### `WatchHealthData$watch_sleep_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 4]
- ⚠️ champ 225 hors bornes [1, 4]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `sleepPeriodSummaryMsg` |
| **139** | `double` | `timestamp` |
| **225** | `oneof:fixed64` | `shortSleepPeriodMsg` |

### `WatchHealthData$watch_sleep_period_stage_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `num` |

### `WatchHealthData$watch_sleep_period_summary_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 10]
- ⚠️ champ 225 hors bornes [1, 10]
- ⚠️ champ 128 hors bornes [1, 10]
- ⚠️ champ 132 hors bornes [1, 10]
- ⚠️ champ 225 hors bornes [1, 10]
- ⚠️ champ 128 hors bornes [1, 10]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `totalTime` |
| **4** | `fixed32` | `deepMinutes` |
| **4** | `oneof:enum` | `wakeMinutes` |
| **128** | `oneof:sint64` | `sleepScore` |
| **128** | `oneof:sint64` | `stageNum` |
| **132** | `uint64` | `remMinutes` |
| **139** | `double` | `startTime` |
| **225** | `oneof:fixed64` | `endTime` |
| **225** | `oneof:fixed64` | `lightMinutes` |

### `WatchHealthData$watch_sleep_stage_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `stage` |

### `Wifi$wifi_data_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 128 hors bornes [1, 7]
- ⚠️ champ 139 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `key` |
| **4** | `oneof:enum` | `signalStrength` |
| **128** | `oneof:sfixed32` | `openStatus` |
| **139** | `double` | `status` |
| **139** | `uint64` | `encryptionType` |
| **225** | `oneof:fixed64` | `ssid` |

### `Wifi$wifi_msg` ⚠️

- ⚠️ champ 140 hors bornes [1, 7]
- ⚠️ champ 225 hors bornes [1, 7]
- ⚠️ champ 137 hors bornes [1, 7]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `wifiDataMsg` |
| **4** | `repeated message` | `wifiSyncStates` |
| **5** | `oneof:enum` | `wifiUrlMsg` |
| **137** | `int64` | `cpuUuid` |
| **140** | `double` | `serviceType` |
| **225** | `oneof:bool` | `wifiOperateType` |

### `Wifi$wifi_quick_upgrade_message` ⚠️

- ⚠️ champ 139 hors bornes [1, 2]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **139** | `double` | `firmwareVersion` |

### `Wifi$wifi_sync_message` ⚠️

- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |

### `Wifi$wifi_url_message` ⚠️

- ⚠️ champ 136 hors bornes [1, 6]
- ⚠️ champ 225 hors bornes [1, 6]
- ⚠️ champ 128 hors bornes [1, 6]
- ⚠️ octets restants en fin de chaîne

| # | Type | Champ |
|---|---|---|
| **1** | `oneof:enum` | `bitField0` |
| **1** | `uint64` | `summaryListUrl` |
| **4** | `oneof:enum` | `acceptLanguage` |
| **128** | `oneof:sfixed32` | `memberId` |
| **136** | `double` | `encryptedMemberId` |
| **225** | `oneof:fixed64` | `baseUrl` |
