<template>
  <h3>条件の設定</h3>
  <div id=overlay  v-show="confirmedSetting">
    <div id=confirm>
      <Confirm v-on:delete="deleteSetting(confirmedSetting.id)"
               v-on:cancel="cancelConfirm">
      </Confirm>
    </div>
  </div>
  <div class="settings-area ">
    <span class="have-no-settings" v-show="props.settings.length === 0">まだ条件がありません</span>
    <div v-for="setting in slicedSettings" :key="setting.id">
      <span class="setting m-2 fs-6 rounded" v-bind:class="{'selected': settingId === setting.id}">
        {{ setting.period_start_at }} 〜 {{ setting.period_end_at }}
      </span>
      <button v-on:click="editSetting(setting)" class="btn btn-sm btn-dark ms-1">編集</button>
      <button v-on:click="reflectSetting(setting)" class="btn btn-sm btn-primary ms-1">適用</button>
      <span v-on:click="confirmDialog(setting)" class="delete-button ms-1">削除</span>
    </div>
  </div>
  <span v-for="pageNumber in displayPageNumbers" :key="pageNumber">
    <span class="page-number m-1 fs-5"
          v-bind:class="{'current-page':currentPage === pageNumber}"
          v-on:click="updatePageNumber(pageNumber)">
      {{ pageNumber }}
    </span>
  </span>
  <div class="new-setting rounded fs-6 my-2" v-bind:class="{'selected': !settingId}" v-on:click="resetSettingParams()">新しい条件を作る</div>
  <br>
  <span class="fs-6 m-1">開始日：</span>
  <select id="start_month_select m-1" v-model="selectedStartMonth">
    <option v-for="month in 12" :key="month">
      {{ month }}
    </option>
  </select>
  <span class="fs-6 m-1">月</span>
  <select id="start_day_select m-1" v-model="selectedStartDay">
    <option v-for="date in lastDate(selectedStartMonth)" :key="date">
      {{ date }}
    </option>
  </select>
  <span class="fs-6 m-1">日</span>
  <br>
  <span class="fs-6 m-1">終了日：</span>
  <select id="end_month_select m-1" v-model="selectedEndMonth">
    <option v-for="month in 12" :key="month">
      {{ month }}
    </option>
  </select>
  <span class="fs-6 m-1">月</span>
  <select id="end_day_select m-1" v-model="selectedEndDay">
    <option v-for="date in lastDate(selectedEndMonth)" :key="date">
      {{ date }}
    </option>
  </select>
  <span class="fs-6 m-1">日</span>
  <div>この期間の勤務日数:
    <input id="specified_total_days my-2" type="number" v-show="specifiedTotalDays" v-model="totalWorkingDays"/>
  </div>
  <label for="check_specified_total_days">指定しない</label>
  <input type="checkbox" id="check_specified_total_days my-2" v-model="notSpecifiedTotalDays" />
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
  <button class="btn btn-dark m-2" v-on:click="emit('close')">閉じる</button>
  <button class="btn btn-success m-2" v-if="settingId" v-on:click="updateSetting(settingId)">変更</button>
  <button class="btn btn-primary m-2" v-else v-on:click="createSetting()">新規作成</button>
  <p v-if="errors.value">
    <b>Please correct the following error(s):</b>
    <ul>
      <li v-for="error in errors.value" :key="error.id">{{ error }}</li>
    </ul>
  </p>
</template>

<script setup>
import { ref, computed } from 'vue'
import Confirm from './confirm.vue'
import { useToast } from "vue-toastification"

const toast = useToast()
const props = defineProps({ 
  year: Number,
  settings: Array
})
const emit = defineEmits(['close', 'update', 'create', 'delete', 'reflect'])
const settingId = ref("")
// CRUD
function token() {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta ? meta.getAttribute('content') : ''
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
    toast("作成しました")
    setting['id'] = json.id
    emit('create', setting)
  })
  .catch((error) => {
    console.warn(error)
  })
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
    toast("更新しました")
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
  cancelConfirm()
  fetch(`api/calendars/${props.year}/settings/${id}`, {
  method: 'DELETE',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': token(),
  },
  credentials: 'same-origin'
  })
  .then(() => {
    toast("削除しました")
    resetSettingParams()
    emit('delete', id)
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
function reflectSetting(setting){
  emit('reflect', setting)
}
// フォーム：期間設定
const selectedStartMonth = ref(1)
const selectedStartDay = ref(1)
const selectedEndMonth = ref(1)
const selectedEndDay = ref(1)
function lastDate(selectedMonth) {
  const lastDay = new Date(props.year, selectedMonth, 0)
  return lastDay.getDate()
}
// フォーム：勤務日数指定
const totalWorkingDays = ref(0)
const notSpecifiedTotalDays = ref(true)
const specifiedTotalDays = computed(() => {
  return !notSpecifiedTotalDays.value
})
function setTotalWorkingDays() {
  if (notSpecifiedTotalDays.value) { return null } 
  return totalWorkingDays.value
}
// フォーム：曜日毎の予定入力
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
// ページング
const currentPage = ref(1)
const pageLimit = 5
function updatePageNumber(pageNumber) {
  currentPage.value = pageNumber
}
const slicedSettings = computed(() => {
  let start = (currentPage.value -1) * pageLimit
  let end = start + pageLimit
  return props.settings.slice(start, end) 
})
const displayPageNumbers = computed(() => {
  let pages = []
  const totalPages = Math.ceil(props.settings.length / pageLimit)
  const displayRange = 1
  if(totalPages < 2) {
    return
  }
  pages.push(1)
  if ((currentPage.value - displayRange) > 2){
    pages.push('...')
  }
  for (let i = 0; i <= displayRange * 2; i++) {
    if ((currentPage.value - displayRange + i > 1) && (currentPage.value - displayRange + i < totalPages)){
      pages.push(currentPage.value - displayRange + i)
    }
  }
  if ((currentPage.value + displayRange) < (totalPages - 1)){
    pages.push('...')
  }
  pages.push(totalPages)
  return pages
})
// 確認ダイアログ
const confirmedSetting = ref(null)
function confirmDialog(setting){
  confirmedSetting.value = setting
}
function cancelConfirm() {
  confirmedSetting.value = null
}
// バリデーション
const errors = ref([])

function formatMonth(month) {
  return month.toString().padStart(2, '0')
}
function formatDay(day) {
  return day.toString().padStart(2, '0')
}
function formatDate(date){
  return (date.getFullYear() + "-" + formatMonth(date.getMonth()+1) + "-" + formatDay(date.getDate()))
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
    const settingStartAt = setting.period_start_at
    const settingEndAt = setting.period_end_at
    const formatedStartDay = formatDate(startDay)
    const formatedEndDay = formatDate(endDay)
    if ((formatedStartDay <= settingStartAt) && (formatedEndDay >= settingStartAt) ||
      (formatedStartDay <= settingEndAt) && (formatedEndDay >= settingEndAt) ||
      (formatedStartDay > settingStartAt) && (formatedEndDay < settingEndAt)) {
      errors.value.push("他の条件の期間と重ならないようにしてください。")
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
</script>

<style>
#confirm{
  z-index:3;
  width:60%;
  padding: 2em;
  background:#fff;
}
.new-setting{
  padding: 2px;
  width:200px;
  text-decoration: underline;
  cursor: pointer;
}
.selected{
  padding: 4px;
  box-shadow:0px 0px 0px 4px #0099ff;
}
.delete-button{
  text-decoration: underline;
  cursor: pointer;
}
.settings-area{
  height: 200px;
}
.setting{
  display: inline-block;
  width: 220px;
}
.page-number{
  text-decoration: underline;
  cursor: pointer;
}
.have-no-settings{
  display: inline-block;
  vertical-align: middle;
}
.current-page{
  font-weight:bold;
}
</style>
