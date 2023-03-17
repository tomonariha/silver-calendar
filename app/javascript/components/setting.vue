<template>
  <p>条件の設定</p>
  <div v-for="setting in props.settings" :key="setting.id">
    <span>{{ setting.period_start_at }} 〜 {{ setting.period_end_at }}</span>
    <button v-on:click="editSetting(setting)">編集</button>
    <button v-on:click="deleteSetting(setting.id)">削除</button>
    <button v-on:click="reflectSetting(setting)">適用</button>
  </div>
  <div v-for="pageNumber in totalPages" :key="pageNumber">
    <button v-on:click="updatePageNumber(pageNumber)">{{ pageNumber }}</button>
  </div>
  <button v-on:click="resetSettingParams()">new</button>
  <br>
  <select id="start_month_select" v-model="selectedStartMonth">
    <option v-for="month in 12" :key="month">
      {{ month }}
    </option>
  </select>
  <select id="start_day_select" v-model="selectedStartDay">
    <option v-for="date in lastDate(selectedStartMonth)" :key="date">
      {{ date }}
    </option>
  </select>
  <br>
  <select id="end_month_select" v-model="selectedEndMonth">
    <option v-for="month in 12" :key="month">
      {{ month }}
    </option>
  </select>
  <select id="end_day_select" v-model="selectedEndDay">
    <option v-for="date in lastDate(selectedEndMonth)" :key="date">
      {{ date }}
    </option>
  </select>
  <div>この期間の勤務日数:
    <input id="specified_total_days" type="number" v-show="specifiedTotalDays" v-model="totalWorkingDays"/>
  </div>
  <label for="check_specified_total_days">指定しない</label>
  <input type="checkbox" id="check_specified_total_days" v-model="notSpecifiedTotalDays" />
  <div>{{ weekdayJp[weekdayNumber] }}曜日の予定</div>
  <button @click='previousWeekday'>前</button>
  <button @click='nextWeekday'>後</button>
  <br/>
  <input type="radio" id="none" value="None" v-model="schedules[weekdayNumber]" />
  <label for="none">予定なし</label>
  <br/>
  <input type="radio" id="full-time" value="full-time" v-model="schedules[weekdayNumber]" />
  <label for="full-time">全日出勤</label>
  <br/>
  <input type="radio" id="morning" value="morning" v-model="schedules[weekdayNumber]" />
  <label for="morning">午前出勤</label>
  <br/>
  <input type="radio" id="afternoon" value="afternoon" v-model="schedules[weekdayNumber]" />
  <label for="afternoon">午後出勤</label>
  <br/>
  <input type="radio" id="off" value="off" v-model="schedules[weekdayNumber]" />
  <label for="off">休み</label>
  <br/>
  <button v-on:click="emit('close')">閉じる</button>
  <button v-if="settingId" v-on:click="updateSetting(settingId)">変更</button>
  <button v-else v-on:click="createSetting()">新規作成</button>
  <p v-if="errors.value">
    <b>Please correct the following error(s):</b>
    <ul>
      <li v-for="error in errors.value" :key="error.id">{{ error }}</li>
    </ul>
  </p>
</template>

<script setup>
import { ref, computed } from 'vue'
const scheduleOfSunday = "off"
const scheduleOfMonday = "None"
const scheduleOfTuesday = "None"
const scheduleOfWednesday = "None"
const scheduleOfThursday = "None"
const scheduleOfFriday = "None"
const scheduleOfSaturday = "off"
const schedules = ref([
  scheduleOfSunday,
  scheduleOfMonday,
  scheduleOfTuesday,
  scheduleOfWednesday,
  scheduleOfThursday,
  scheduleOfFriday,
  scheduleOfSaturday
])
const selectedStartMonth = ref(1)
const selectedStartDay = ref(1)
const selectedEndMonth = ref(1)
const selectedEndDay = ref(1)
const settingId = ref("")
const totalWorkingDays = ref(0)
const notSpecifiedTotalDays = ref(true)
const weekdayNumber = ref(0)
const weekdayJp = {
        0: "日",
        1: "月",
        2: "火",
        3: "水",
        4: "木",
        5: "金",
        6: "土",
      }
const errors = ref([])
const currentPage = ref(1)
const pageLimit = ref(5)
const emit = defineEmits(['close', 'update', 'create', 'delete', 'reflect'])
const props = defineProps({ 
    year: Number,
    settings: Array})
//computed
const specifiedTotalDays = computed(() => {
      return !notSpecifiedTotalDays.value
    })
const slicedSettings = computed(() => {
  let start = (currentPage.value -1) * pageLimit.value
  let end = start + pageLimit.value
  return props.settings.slice(start, end) 
})
  
const totalPages = computed(() => {
  return Math.ceil(props.settings.length / pageLimit.value)
})
//ここまでcomp
 
function token() {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta ? meta.getAttribute('content') : ''
}
function updatePageNumber(pageNumber) {
  currentPage.value = pageNumber
}
function lastDate(selectedMonth) {
  const lastDay = new Date(props.year, selectedMonth, 0)
  return lastDay.getDate()
}
function updateSetting(settingId) {
  const startDay = new Date(props.year, (selectedStartMonth.value - 1), selectedStartDay.value)
  const endDay = new Date(props.year, (selectedEndMonth.value - 1), selectedEndDay.value)
  if (totalDaysValidation(startDay, endDay)) { return }
  if (periodValidation(startDay, endDay)) { return }
  const setting = {
    period_start_at: startDay.toDateString(),
    period_end_at: endDay.toDateString(),
    total_working_days: setTotalWorkingDays(),
    schedule_of_sunday: schedules.value[0],
    schedule_of_monday: schedules.value[1],
    schedule_of_tuesday: schedules.value[2],
    schedule_of_wednesday: schedules.value[3],
    schedule_of_thursday: schedules.value[4],
    schedule_of_friday: schedules.value[5],
    schedule_of_saturday: schedules.value[6],
  }
  fetch(`api/calendars/${props.year}/settings/${settingId}`, {
  method: 'PUT',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': token(),
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(setting),
  credentials: 'same-origin'
  })
  .then(() => {
    setting['id'] = settingId
    emit('update', setting)
  })
  .catch((error) => {
    console.warn(error)
  }) 
}
function editSetting(setting) {
  const startDay = new Date(setting.period_start_at)
  const endDay = new Date(setting.period_end_at)
  totalWorkingDays.value = setting.total_working_days
  schedules.value[0] = setting.schedule_of_sunday
  schedules.value[1] = setting.schedule_of_monday
  schedules.value[2] = setting.schedule_of_tuesday
  schedules.value[3] = setting.schedule_of_wednesday
  schedules.value[4] = setting.schedule_of_thursday
  schedules.value[5] = setting.schedule_of_friday
  schedules.value[6] = setting.schedule_of_saturday
  selectedStartMonth.value = (startDay.getMonth() + 1)
  selectedStartDay.value = startDay.getDate()
  selectedEndMonth.value = (endDay.getMonth() + 1)
  selectedEndDay.value = endDay.getDate()
  settingId.value = setting.id
  weekdayNumber.value = 0
  if (setting.total_working_days) {
    notSpecifiedTotalDays.value = false
  } else {
    notSpecifiedTotalDays.value = true
  }
}
function deleteSetting(id) {
  fetch(`api/calendars/${props.year}/settings/${id}`, {
  method: 'DELETE',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': token(),
  },
  credentials: 'same-origin'
  })
  .then(() => {
    resetSettingParams()
    emit('delete', id)
  })
  .catch((error) => {
    console.warn(error)
  })
}
function createSetting() {
  const startDay = new Date(props.year, (selectedStartMonth.value - 1), selectedStartDay.value)
  const endDay = new Date(props.year, (selectedEndMonth.value - 1), selectedEndDay.value)
  if (totalDaysValidation(startDay, endDay)) { return }
  if (periodValidation(startDay, endDay)) { return }
  const setting = {
    period_start_at: startDay.toDateString(),
    period_end_at: endDay.toDateString(),
    total_working_days: setTotalWorkingDays(),
    schedule_of_sunday: schedules.value[0],
    schedule_of_monday: schedules.value[1],
    schedule_of_tuesday: schedules.value[2],
    schedule_of_wednesday: schedules.value[3],
    schedule_of_thursday: schedules.value[4],
    schedule_of_friday: schedules.value[5],
    schedule_of_saturday: schedules.value[6],
  }
  fetch(`api/calendars/${props.year}/settings`, {
  method: 'POST',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': token(),
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(setting),
  credentials: 'same-origin'
  })
  .then((response) => {
    return response.json()
  })
  .then((json) => {
    setting['id'] = json.id
    emit('create', setting)
  })
  .catch((error) => {
    console.warn(error)
  })
}
function resetSettingParams() {
  schedules.value[0] = "off"
  schedules.value[1] = "None"
  schedules.value[2] = "None"
  schedules.value[3] = "None"
  schedules.value[4] = "None"
  schedules.value[5] = "None"
  schedules.value[6] = "off"
  selectedStartMonth.value = 1
  selectedStartDay.value = 1
  selectedEndMonth.value = 1
  selectedEndDay.value = 1
  settingId.value = ""
  totalWorkingDays.value = 0
  weekdayNumber.value = 0
  notSpecifiedTotalDays.value = true
}
function setTotalWorkingDays() {
  if (notSpecifiedTotalDays.value) { return null } 
  return totalWorkingDays.value
}
function previousWeekday() {
  if (weekdayNumber.value === 0) {
    weekdayNumber.value = 6
  } else {
    weekdayNumber.value--
  }
}
function nextWeekday() {
  if (weekdayNumber.value === 6) {
    weekdayNumber.value = 0
  } else {
    weekdayNumber.value++
  }
}
function periodValidation(startDay, endDay) {
  errors.value = []
  let invalid = false
  if (!selectedStartMonth.value || !selectedStartDay.value || !selectedEndMonth.value || !selectedEndDay.value) {
    errors.values.push("開始日と終了日を入力してください。")
    return true
  }
  if (startDay > endDay) {
    errors.value.push("開始日が終了日以前になるようにしてください。")
    return true
  }
  for (let setting of props.settings) {
    if (setting.id === settingId.value) { continue }
    const settingStartAt = new Date(setting.period_start_at)
    const settingEndAt = new Date(setting.period_end_at)
    if (((startDay <= settingStartAt) && (endDay >= settingStartAt)) ||
      ((startDay <= settingEndAt) && (endDay >= settingEndAt)) ||
      ((startDay > settingStartAt) && (endDay < settingEndAt))) {
      errors.push("他の条件の期間と重ならないようにしてください。")
      invalid = true
      break
    }
  }
  if (invalid) { return true }
}
function totalDaysValidation(startDay, endDay) {
  errors.value = []
  let calendar = []
  for (let day = new Date(startDay.getTime()); day <= endDay; day.setDate(day.getDate()+1)) {
    calendar.push(day)
  }
  if ((totalWorkingDays.value < 0)||(totalWorkingDays.value > calendar.length)) {
    errors.value.push(`勤務日数は０以上期間内の日数(${calendar.length})以下にしてください。`)
    return true
  }
}
function reflectSetting(setting){
  emit('reflect', setting)
}
</script>
