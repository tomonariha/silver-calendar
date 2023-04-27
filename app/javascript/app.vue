<template>
  <button class="calendar-nav__previous" v-show="monthly" @click='previousMonth'>＜</button>
  <button class="calendar-nav__next" v-show="monthly" @click='nextMonth'>＞</button>
  <select id='specifiy_calendar_year' v-model.number="calendarYear" @change="cancelAutoAdjust">
    <option v-for="year in rangeOfYears" :key="year">{{ year }}</option>
  </select>
  <select id='specifiy_calendar_month' v-show="monthly" v-model.number="calendarMonth">
    <option v-for="month in 12" :key="month">{{ month }}</option>
  </select>
  <div v-show="autoAdjusted">
    <div class="auto-adjust-info rounded col-3" v-if="workingDaysRequired"  v-bind:class="{'not-just': numberOfWorkingDays !== workingDaysRequired}">
      <p>期間:{{showPeriod()}}</p>
      <p class="current-working-days">
        (現在の日数){{ numberOfWorkingDays }} / {{ workingDaysRequired }}(必要日数)</p>
    </div>
    <div v-else>{{ numberOfWorkingDays }}</div>
  </div>
  <div id=overlay v-show="showConfirm">
    <div id=content>
      <Confirm v-on:delete='deleteCalendar'
               v-on:cancel='cancelConfirm'>
      </Confirm>
    </div>
  </div>
  <div v-if="monthly">
    <div class="calendar-nav__year--month">{{ calendarYear }}年{{ calendarMonth }}月 合計:{{ totalWorkingDays[calendarMonth] }}</div>
    <button class="btn btn-secondary m-2" v-on:click="toYearyCalendar">年間カレンダー</button>
    <table class="monthly-calendar">
      <thead class="monthly-calendar__header">
        <tr>
          <th class="monthly-calendar__header-day">日</th>
          <th class="monthly-calendar__header-day">月</th>
          <th class="monthly-calendar__header-day">火</th>
          <th class="monthly-calendar__header-day">水</th>
          <th class="monthly-calendar__header-day">木</th>
          <th class="monthly-calendar__header-day">金</th>
          <th class="monthly-calendar__header-day">土</th>
        </tr>
      </thead>
      <tbody v-for="week in calendarWeeks(calendarMonth)" :key="week.id">
        <tr class="monthly-calendar__week">
          <td class="monthly-calendar__day" 
            v-for='date in week.value'
            :key='date.date'
            :id="'day' + date.date">
            <div class="monthly-calendar__day-label">{{ date.date }}</div>
            <div>
              <Day v-bind:date="date"
                   v-bind:autoAdjusted="autoAdjusted"
                   v-bind:class="{'disabled': autoAdjusted && outsideWithinPeriod(date, reflectedSetting)}"
                   v-if="date.date"
                   v-on:update="updateDay"
                   v-on:delete="deleteDay">
              </Day>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
  <div v-else>
    <div class="calendar-nav__year">{{ calendarYear }}年 合計:{{ yearyTotalWorkingDays() }}</div>
    <div class="yeary-calendar-month rounded p-1" v-for="month in 12" :key="month" v-on:click="toMonthlyCalendar(month)">{{ month }}月 合計:{{ totalWorkingDays[month] }}
      <table class="yeary-calendar">
        <thead class="yeary-calendar__header">
          <tr>
            <th class="yeary-calendar__header-day">日</th>
            <th class="yeary-calendar__header-day">月</th>
            <th class="yeary-calendar__header-day">火</th>
            <th class="yeary-calendar__header-day">水</th>
            <th class="yeary-calendar__header-day">木</th>
            <th class="yeary-calendar__header-day">金</th>
            <th class="yeary-calendar__header-day">土</th>
          </tr>
        </thead>
        <tbody v-for="week in calendarWeeks(month)" :key="week.id">
          <tr class="yeary-calendar__week">
            <td class="yeary-calendar__day" 
              v-for='date in week.value'
              :key='date.date'
              :id="'day' + date.date">
              <div class="yeary-calendar__day-label">{{ date.date }}</div>
              <div v-show="date.date" class="yeary-calendar__day-body" v-bind:class="{'auto-adjusted': autoAdjusted && !outsideWithinPeriod(date, reflectedSetting)}">
                <span v-if="date.schedule==='full-time'">
                  <img :src="fullTime" alt="fullTime" width="16" height="16"/>
                </span>
                <span v-else-if="date.schedule==='morning'">
                  <img :src="morning" alt="morning" width="16" height="16"/>
                </span>
                <span v-else-if="date.schedule==='afternoon'">
                  <img :src="afterNoon" alt="afternoon" width="16" height="16"/>
                </span>
                <span v-else-if="date.schedule==='off'">
                  <img :src="off" alt="off" width="16" height="16"/>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
  <button class="btn btn-primary m-2" v-show="unAutoAdjusted" v-on:click="openModal">条件の入力</button>
    <div id=overlay  v-show="showContent">
      <div id=content>
        <Setting v-bind:year="calendarYear"
               v-bind:settings="settings"
               v-on:close="closeModal"
               v-on:update="updateSetting"
               v-on:create="createSetting"
               v-on:delete="deleteSetting"
               v-on:reflect="adjustAndReflect">
        </Setting>
      </div>
    </div>
  <button type="button" class="btn btn-success m-2" v-show="autoAdjusted" v-on:click="determineAutoAdjust">確定</button>
  <button type="button" class="btn btn-secondary m-2" v-show="autoAdjusted" v-on:click="cancelAutoAdjust">キャンセル</button>
  <button type="button" class="btn btn-primary m-2" v-show="unAutoAdjusted" v-on:click="openAlignmentModal">連携</button>
    <div id=overlay  v-show="showAlignmentContent">
      <div id=content>
        <Alignment v-bind:calendars="calendarsIndex"
                   v-on:close="closeAlignmentModal"
                   v-on:create="createAlignment"
                   v-on:delete="deleteAlignment"
                   v-on:update="updateAlignment">
        </Alignment>
      </div>
    </div>
  <span class="delete-calendar m-2" 
    v-show="unAutoAdjusted" v-on:click="confirmDeleteCalendar">削除する
  </span>
</template>

<script setup>
import { ref, computed, defineProps, onMounted, nextTick } from 'vue'
import { useToast } from "vue-toastification"
import Setting from './components/setting.vue' 
import Day from './components/day.vue' 
import Alignment from './components/alignment.vue'
import Confirm from './components/confirm.vue'
import fullTime from '../assets/images/fulltime.svg?url'
import morning from '../assets/images/morning.svg?url'
import afterNoon from '../assets/images/afternoon.svg?url'
import off from '../assets/images/off.svg?url'

function showPeriod() {
  if (reflectedSetting.value) {
    const periodOfReflectedSetting = `${reflectedSetting.value.period_start_at} ~ ${reflectedSetting.value.period_end_at}` 
    return periodOfReflectedSetting
  }
}
const toast = useToast()
const props = defineProps({ userId: String })
onMounted(() => {
  fetchCalendar().then(function() {
    fetchSettings();
  })
  fetchCalendarsIndex()
})
//カレンダー表示関連
const scheduleToMark = { "full-time":"●", "morning":"▲", "afternoon":"△", "off":"□" }
const calendarYear = ref(getCurrentYear())
function getCurrentYear() {
  return new Date().getFullYear()
}
const calendarMonth = ref(getCurrentMonth())
function getCurrentMonth() {
  return new Date().getMonth() + 1
}
function previousMonth() {
  loaded.value = false
  if (calendarMonth.value === 1) {
    calendarMonth.value = 12
    calendarYear.value--
    cancelAutoAdjust()
  } else {
    calendarMonth.value--
  }
  nextTick(() => (loaded.value = true))
}
function nextMonth() {
  loaded.value = false
  if (calendarMonth.value === 12) {
    calendarMonth.value = 1
    calendarYear.value++
    cancelAutoAdjust()
  } else {
    calendarMonth.value++
  }
  nextTick(() => (loaded.value = true))
}
function getCurrentDay() {
  return new Date().getDate()
}
function token() {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta ? meta.getAttribute('content') : ''
}
const loaded = ref(null)
const calendarDays = ref([])
function fetchCalendar() {
  return new Promise(function(resolve, reject) {
    calendarDays.value = []
    fetch(`/api/calendars/${calendarYear.value}.json`, {
    method: 'GET',
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token()
    },
    credentials: 'same-origin'
    })
    .then((response) => {
      return response.json()
    })
    .then((json) => {
      json.forEach((r) => {
        calendarDays.value.push(r)
      })
      loaded.value = true
    })
    .catch((error) => {
      console.warn(error)
    })
    resolve()
  })
}
function calendarWeeks(month) {
  const weeksAry = []
  let value = []
  let id = 1
  let weekDay = 0
  calendarDates(month).forEach(function (date, i, ary) {
    !date ? (date = { weekDay: weekDay }) : (date.weekDay = weekDay)
    value.push(date)
    weekDay++
    if (value.length === 7 || i === ary.length - 1) {
      weeksAry.push({ id: id, value: value })
      id++
      value = []
      weekDay = 0
    }
  })
  return weeksAry
}
function calendarDates(month) {
  const calendar = []
  let monthlyTotalWorkingDays = 0
  if (firstWday(month) > 0) {
    for (let blank = 0; blank < firstWday(month); blank++) {
      calendar.push(null)
    }
  }
  for (let date = 1; date <= lastDate(month); date++) {
    const result = calendarDays.value.filter((day) =>
      day.date.includes(
        `${calendarYear.value}-${formatMonth(month)}-${formatDay(date)}`
      )
    )
    if (result.length > 0) {
      const schedule = String(result[0].schedule)
      calendar.push({ 
        date: date,
        schedule: schedule,
        year: calendarYear.value,
        month: month
      })
      monthlyTotalWorkingDays += countWorkingDays(schedule) 
    } else {
      calendar.push({
        date: date, 
        schedule: null,
        year: calendarYear.value,
        month: month
      })
    }
  }
  totalWorkingDays.value[month] = monthlyTotalWorkingDays
  return calendar
}
function firstWday(month) {
  const firstDay = new Date(calendarYear.value, month - 1, 1)
  return firstDay.getDay()
}
function lastDate(month) {
  const lastDay = new Date(calendarYear.value, month, 0)
  return lastDay.getDate()
}
const rangeOfYears = computed(() => {
  let rangeOfYears = []
  const yearRangeNumber = 10
  const pastYear = getCurrentYear() - yearRangeNumber
  const futureYear = getCurrentYear() + yearRangeNumber
  for (let year = pastYear;year < futureYear;year++) {
    rangeOfYears.push(year)
  }
  return rangeOfYears
})
const monthly = ref(true)
function toMonthlyCalendar(month) {
  calendarMonth.value = month
  monthly.value = true
}
function toYearyCalendar(){
  monthly.value = false
}
//勤務日数カウント関連
const totalWorkingDays = ref({})
function countWorkingDays(schedule) {
  if (schedule === 'full-time') {
    return 1
  } else if ((schedule === 'morning') || (schedule === 'afternoon')) {
    return 0.5
  }
  return 0
}
function yearyTotalWorkingDays(){
  let totalDays = 0
  for (let i = 1; i <= 12; i++) {
    totalDays += totalWorkingDays.value[i]
  }
  return totalDays
}
//自動調整関連
const adjustedCalendar = ref([])
const autoAdjusted = ref(false)
const unAutoAdjusted = computed(() => {
  return !autoAdjusted.value
})
const workingDaysRequired = ref(null)
const numberOfWorkingDays = ref(0)
const reflectedSetting = ref(null)
function outsideWithinPeriod(date, setting) {
  if (!date.date) {
    return false
  }
  const formatedDate = (date.year + "-" + formatMonth(date.month) + "-" + formatDay(date.date))
  if (formatedDate < setting.period_start_at) {
    return true
  }
  if (formatedDate > setting.period_end_at) {
    return true
  }
  return false
}
function alertUnChangeable() {
  toast.error(`自動調整の期間外なので変更できません \n
    期間：${reflectedSetting.value.period_start_at} ~ ${reflectedSetting.value.period_end_at}`)
}
function autoAdjust(setting) {
  const startDate = new Date(setting.period_start_at)
  const endDate = new Date(setting.period_end_at)
  let availableDays = new Array()
  let anyDays = new Array()
  workingDaysRequired.value = setting.total_working_days
  numberOfWorkingDays.value = 0
  const schedulesOfWeek = { 
    0: setting.schedule_of_sunday,
    1: setting.schedule_of_monday,
    2: setting.schedule_of_tuesday,
    3: setting.schedule_of_wednesday,
    4: setting.schedule_of_thursday,
    5: setting.schedule_of_friday,
    6: setting.schedule_of_saturday,
  }
  // 期間内の日付オブジェクトを利用可能日の配列へ入れる
  for (let day = startDate; day <= endDate; day.setDate(day.getDate()+1)) {
    const formatedDate = day.getFullYear() + "-" + (day.getMonth()+1) + "-" + day.getDate()
    availableDays.push(formatedDate)
  }
  // CalendarDays配列に入っている期間内の日付オブジェクトを抽出し、
  // その日付の勤務予定の日数をカウントし、利用可能日の配列から取り除く
  extractCalendarDaysWithinPeriod(startDate, endDate).forEach(day=> {
    const date = new Date(day.date)
    availableDays.forEach(availableDay=> {
      const availableDate = new Date(availableDay)
      if (equalDays(availableDate, date)) {
        numberOfWorkingDays.value += countWorkingDays(day.schedule)
        availableDays.splice(availableDays.indexOf(availableDay), 1)
      }
    })
  })
  for (let availableDay of availableDays) {
    const day = new Date(availableDay)
    const schedule = schedulesOfWeek[day.getDay()]
    if (schedule === "None") { 
      anyDays.push(availableDay)
      continue
    }
    if ((workingDaysRequired.value) && (numberOfWorkingDays.value >= workingDaysRequired.value) && !(schedule === "off")) {
      continue
    }
    numberOfWorkingDays.value += countWorkingDays(schedule)
    insertSchedule(day, schedule)
  }
  if (anyDays.length > 0) {
    for (let anyDay of anyDays) {
      const day = new Date(anyDay)
      if (workingDaysRequired.value - numberOfWorkingDays.value === 0.5) {
        insertSchedule(day, "morning")
        numberOfWorkingDays.value+=0.5
      } else if (workingDaysRequired.value - numberOfWorkingDays.value >= 1){
        insertSchedule(day, "full-time")
        numberOfWorkingDays.value++
      } else {
        break
      }
    }
  }
  reflectedSetting.value = setting
  autoAdjusted.value = true
  calendarMonth.value = (startDate.getMonth() + 1)
}
function equalDays(availableDate, date) {
  if (availableDate.getMonth() !== date.getMonth()) { return false }
  if (availableDate.getDate() !== date.getDate()) { return false }
  return true
}
function insertSchedule(day, schedule) {
  const formatedDate = day.getFullYear() + "-" + formatMonth(day.getMonth()+1) + "-" + formatDay(day.getDate())
  adjustedCalendar.value.push({
    date: formatedDate,
    schedule: schedule,
  })
}
function formatMonth(month) {
  return month.toString().padStart(2, '0')
}
function formatDay(day) {
  return day.toString().padStart(2, '0')
}
function reflectAdjustedCalendar() {
  searchAdjustedDay:
  for (let d of adjustedCalendar.value) {
    for (let day of calendarDays.value) {
      if (day.date === d.date) {
        calendarDays.value.splice(calendarDays.value.indexOf(day), 1, d)
        continue searchAdjustedDay
      }
    }
    calendarDays.value.push(d)
  }
}
function extractCalendarDaysWithinPeriod(startDate, endDate) {
  const calendar = new Array()
  for (let day of calendarDays.value) {
    const date = new Date(day) 
    if (date.getMonth() < startDate.getMonth()) {
      continue
    }
    if (date.getMonth() > endDate.getMonth()) {
      continue
    }
    if (date.getDate() < startDate.getDate()) {
      continue
    }
    if (date.getDate() > endDate.getDate()) {
      continue
    }
    calendar.push(day)
  }
  return calendar
}
function determineAutoAdjust() {
  saveAdjustedCalendar()
  toast("適用しました")
  autoAdjusted.value = false
}
function cancelAutoAdjust() {
  adjustedCalendar.value = [],
  fetchCalendar().then(function() {
    fetchSettings();
  })
  reflectedSetting.value = null
  autoAdjusted.value = false
}
function saveAdjustedCalendar() {
  fetch(`api/calendars/${calendarYear.value}`, {
  method: 'PUT',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': token(),
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ "calendar": adjustedCalendar.value }),
  credentials: 'same-origin'
  })
  .catch((error) => {
    console.warn(error)
  })
  adjustedCalendar.value = []
}
function adjustAndReflect(setting) {
  (async () => {
    await closeModal()
    await autoAdjust(setting)
    await reflectAdjustedCalendar()
  })()
}
//条件設定関連
const settings = ref([])
function fetchSettings() {
  settings.value = []
  fetch(`api/calendars/${calendarYear.value}/settings.json`, {
    method: 'GET',
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token()
    },
    credentials: 'same-origin'
  })
  .then((response) => {
    return response.json()
  })
  .then((json) => {
    json.forEach((r) => {
      settings.value.push(r)
    })
    loaded.value = true
  })
  .then(()=> {
    sortSettings()
  })
  .catch((error) => {
    console.warn(error)
  })
}
function sortSettings() {
  settings.value.sort((a, b)=>
    a.period_start_at > b.period_start_at ? 1 : -1
  )
}
const showContent = ref(false)
function openModal() {
  showContent.value = true
}
function closeModal() {
  showContent.value = false
}
function formatUpdatedDay(updatedDay) {
  let day = new Date(updatedDay)
  const formatedUpdatedDay = day.getFullYear() + "-" + formatMonth(day.getMonth() + 1) + "-" + formatDay(day.getDate())
  return formatedUpdatedDay
}
function createSetting(createdSetting) {
  createdSetting.period_start_at = formatUpdatedDay(createdSetting.period_start_at)
  createdSetting.period_end_at = formatUpdatedDay(createdSetting.period_end_at)
  settings.value.push(createdSetting)
  sortSettings()
}
function deleteSetting(settingId) {
  for (let setting of settings.value) {
    if (setting.id === settingId) {
      settings.value.splice(settings.value.indexOf(setting), 1)
      break
    }
  }
}
function updateSetting(updatedSetting) {
  updatedSetting.period_start_at = formatUpdatedDay(updatedSetting.period_start_at)
  updatedSetting.period_end_at = formatUpdatedDay(updatedSetting.period_end_at)
  for (let setting of settings.value) {
    if(setting.id === updatedSetting.id) {
      settings.value.splice(settings.value.indexOf(setting), 1, updatedSetting)
      break
    }
  }
  sortSettings()
}
//勤務入力関連
function updateDay(day) {
  const date = new Date(day.year, day.month - 1, day.date)
  const formatedDay = formatUpdatedDay(date)
  const newDay = { date: formatedDay, schedule: day.schedule }
  const diff = updateToCalendarArray(calendarDays.value, newDay)
  if (autoAdjusted.value) {
    numberOfWorkingDays.value += diff
    updateToCalendarArray(adjustedCalendar.value, newDay)
  } 
}
function updateToCalendarArray(calendarDays, newDay){
  for (let calendarDay of calendarDays) {
    if (calendarDay.date === newDay.date) {
      countWorkingDays(calendarDay.schedule) - countWorkingDays(newDay.schedule)
      calendarDays.splice(calendarDays.indexOf(calendarDay), 1, newDay)
      return (countWorkingDays(newDay.schedule) - countWorkingDays(calendarDay.schedule)) 
    }
  }
  calendarDays.push(newDay)
  return countWorkingDays(newDay.schedule)
}
function deleteDay(day) {
  const date = new Date(day.year, day.month - 1, day.date)
  const formatedDay = formatUpdatedDay(date)
  const diffAmount = deleteFromCalendarArray(calendarDays.value, formatedDay)
  if (autoAdjusted.value) {
    numberOfWorkingDays.value -= diffAmount
    deleteFromCalendarArray(adjustedCalendar.value, formatedDay)
  }
}
function deleteFromCalendarArray(calendarDays, formatedDay) {
  for (let calendarDay of calendarDays) {
  if (calendarDay.date === formatedDay) {
    calendarDays.splice(calendarDays.indexOf(calendarDay), 1)
    return countWorkingDays(calendarDay.schedule)
    }
  }
}
// 確認ダイアログ
const showConfirm = ref(false)
function confirmDeleteCalendar(){
  fetchCalendar().then(function() {
    fetchSettings();
  })
  showConfirm.value = true
}
function cancelConfirm() {
  showConfirm.value = false
}
function deleteCalendar() {
  fetch(`api/calendars/${calendarYear.value}`, {
  method: 'DELETE',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': token(),
  },
  credentials: 'same-origin'
  })
  .then(() => {
    toast("削除しました")
    calendarDays.value = []
    settings.value = []
    deleteFromCalendarsIndex()
  })
  .catch((error) => {
    console.warn(error)
  })
  cancelConfirm()
}
function deleteFromCalendarsIndex() {
  for (let calendar of calendarsIndex.value) {
    if (calendarYear.value === calendar.year) {
      calendarsIndex.value.splice(calendarsIndex.value.indexOf(calendar), 1)
      break
    }
  }
}
//外部アプリ連携関連
const showAlignmentContent = ref(false)
function openAlignmentModal() {
  fetchCalendarsIndex()
  showAlignmentContent.value = true
}
function closeAlignmentModal() {
  showAlignmentContent.value = false
}
const calendarsIndex = ref([])
function fetchCalendarsIndex() {
  calendarsIndex.value = []
  fetch('api/calendars', {
  method: 'GET',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': token()
  },
  credentials: 'same-origin'
  })
  .then((response) => {
    return response.json()
  })
  .then((json) => {
    json.forEach((r) => {
      calendarsIndex.value.push(r)
    })
  })
  .then(()=> {
    calendarsIndex.value.sort((a, b)=>
      a.year - b.year
    )
  })
  .catch((error) => {
    console.warn(error)
  })
}
function createAlignment(calendar) {
  for (let calendarIndex of calendarsIndex.value) {
    if (calendarIndex.year === calendar.year) {
      calendarIndex.google_calendar_id = calendar.google_calendar_id
      break
    }
  }
}
function deleteAlignment(calendar) {
  for (let calendarIndex of calendarsIndex.value) {
    if (calendarIndex.year === calendar.year) {
      calendarIndex.google_calendar_id = null
      break
    }
  }
}
function updateAlignment(calendar) {
  for (let calendarIndex of calendarsIndex.value) {
    if (calendarIndex.year === calendar.year) {
      calendarIndex.google_calendar_id = calendar.google_calendar_id
      break
    }
  }
}
</script>

<style>
#overlay{
  z-index:1;
  position:fixed;
  top:0;
  left:0;
  width:100%;
  height:100%;
  background-color:rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
#content{
  z-index:2;
  width:70%;
  padding: 1em;
  background:#fff;
}
.yeary-calendar-month{
  display: inline-block;
  height: 350px;
}
.yeary-calendar-month:hover{
  box-shadow: 0px 0px 0px 4px #0099ff;
}
.yeary-calendar__day-body{
  height: 20px;
  display: table-cell;
  vertical-align: middle;
}
.disabled{
  pointer-events: none;
}
.auto-adjusted{
  background-color: lightskyblue;
}
.auto-adjust-info{
  border: 3px solid lightgreen;
}
.not-just{
  border:2px solid #ff6600
}
.delete-calendar{
  text-decoration: underline;
  cursor: pointer;
}
</style>
