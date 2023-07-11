<template>
  <div>
    <Setting
      v-show="unAutoAdjusted"
      v-bind:year="calendarYear"
      v-bind:settings="settings"
      v-on:reflect="adjustAndReflect"
      v-on:reflectAll="adjustAndReflectAll">
    </Setting>
    <section>
      <h2 class="fs-5 mt-4">日毎に予定を入力する</h2>
      <div class="my-2 content-center" v-show="autoAdjusted">
        <div class="auto-adjust-info rounded" v-if="autoAdjustAll">
          <p>条件を一括適用しました</p>
        </div>
        <div
          class="auto-adjust-info rounded"
          v-else-if="workingDaysRequired"
          v-bind:class="{
            'not-just': numberOfWorkingDays !== workingDaysRequired
          }">
          <p>期間:{{ showPeriod() }}</p>
          <p class="current-working-days">
            (現在の日数){{ numberOfWorkingDays }} /
            {{ workingDaysRequired }}(必要日数)
          </p>
        </div>
        <div class="auto-adjust-info rounded" v-else>
          <p>期間:{{ showPeriod() }}</p>
          <p class="current-working-days rounded">
            (現在の日数){{ numberOfWorkingDays }}
          </p>
        </div>
        <div
          id="overlay"
          v-show="showJustNotConfirm"
          v-on:click.self="cancelJustNotConfirm">
          <div id="confirm">
            <Confirm
              v-bind:message="'日数に過不足がありますが、確定してよろしいですか？'"
              v-on:execution="determineAutoAdjust"
              v-on:cancel="cancelJustNotConfirm">
            </Confirm>
          </div>
        </div>
        <div class="my-2">
          <span v-if="numberOfWorkingDays !== workingDaysRequired">
            <button
              type="button"
              class="btn btn-success my-2 me-2"
              v-show="autoAdjusted"
              v-on:click="confirmJustNot">
              確定
            </button>
          </span>
          <span v-else>
            <button
              type="button"
              class="btn btn-success my-2 me-2"
              v-show="autoAdjusted"
              v-on:click="determineAutoAdjust">
              確定
            </button>
          </span>
          <button
            type="button"
            class="btn btn-secondary my-2 me-2"
            v-show="autoAdjusted"
            v-on:click="cancelAutoAdjust">
            キャンセル
          </button>
        </div>
      </div>
      <div
        id="overlay"
        v-show="showDeleteConfirm"
        v-on:click.self="cancelDeleteConfirm">
        <div id="confirm">
          <Confirm
            v-bind:message="'削除します。よろしいですか？'"
            v-on:execution="deleteCalendar"
            v-on:cancel="cancelDeleteConfirm">
          </Confirm>
        </div>
      </div>
      <div class="content-center">
        <button
          class="calendar-nav__previous me-1"
          v-show="monthly"
          @click="previousMonth">
          ＜
        </button>
        <select
          id="selected_calendar_year"
          v-model.number="calendarYear"
          @change="cancelAutoAdjust">
          <option v-for="year in rangeOfYears" :key="year">{{ year }}</option>
        </select>
        <span class="mx-1">年</span>
        <select
          id="selected_calendar_month"
          v-show="monthly"
          v-model.number="calendarMonth">
          <option v-for="month in 12" :key="month">{{ month }}</option>
        </select>
        <span class="mx-1" v-show="monthly">月</span>
        <button
          class="calendar-nav__next me-1"
          v-show="monthly"
          @click="nextMonth">
          ＞
        </button>
        <button
          class="btn btn-secondary my-1 mx-4"
          v-on:click="toYearyCalendar"
          v-if="monthly">
          年間カレンダー
        </button>
        <span class="my-1 mx-4 text-primary" v-else>
          月のカレンダーをクリックすると月間カレンダーになります
        </span>
      </div>
      <div class="my-2 content-center" v-if="monthly">
        <div class="calendar-nav__year my-2">
          {{ calendarYear }}年{{ calendarMonth }}月 合計:{{
            totalWorkingDays[calendarMonth]
          }}
          有給：{{ totalPaidLeaves[calendarMonth] }}
        </div>
        <ScheduleDescription></ScheduleDescription>
        <div class="monthly-calendar">
          <table class="monthly-calendar__table">
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
                <td
                  class="monthly-calendar__day"
                  v-for="date in week.value"
                  :key="date.date"
                  :id="'day' + date.date">
                  <div class="monthly-calendar__day-label">{{ date.date }}</div>
                  <Day
                    v-bind:date="date"
                    v-bind:autoAdjusted="autoAdjusted"
                    v-bind:exist="existInPeriod(date)"
                    v-bind:class="{
                      disabled:
                        !autoAdjustAll && autoAdjusted && !existInPeriod(date)
                    }"
                    v-if="date.date"
                    v-on:update="updateDay"
                    v-on:delete="deleteDay">
                  </Day>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="content-center" v-else>
        <div class="calendar-nav__year my-2">
          {{ calendarYear }}年 合計:{{ yearyTotalWorkingDays() }} 有給：{{
            yearyTotalPaidLeaves()
          }}
        </div>
        <ScheduleDescription></ScheduleDescription>
        <div
          class="yeary-calendar rounded p-1 me-2 my-1"
          v-for="month in 12"
          :key="month"
          v-on:click="toMonthlyCalendar(month)">
          {{ month }}月 合計:{{ totalWorkingDays[month] }} 有給：{{
            totalPaidLeaves[month]
          }}
          <table class="yeary-calendar__table">
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
                <td
                  class="yeary-calendar__day"
                  v-for="date in week.value"
                  :key="date.date"
                  :id="'day' + date.date">
                  <div class="yeary-calendar__day-label">{{ date.date }}</div>
                  <div
                    v-show="date.date"
                    class="yeary-calendar__day-body"
                    v-bind:class="{
                      'auto-adjusted': autoAdjusted && existInPeriod(date)
                    }">
                    <span v-if="date.schedule === 'full-time'">
                      <img
                        class="yeary-calendar__schedule-icon"
                        :src="fullTime"
                        alt="fullTime" />
                    </span>
                    <span v-else-if="date.schedule === 'morning'">
                      <img
                        class="yeary-calendar__schedule-icon"
                        :src="morning"
                        alt="morning" />
                    </span>
                    <span v-else-if="date.schedule === 'afternoon'">
                      <img
                        class="yeary-calendar__schedule-icon"
                        :src="afterNoon"
                        alt="afternoon" />
                    </span>
                    <span v-else-if="date.schedule === 'off'">
                      <img
                        class="yeary-calendar__schedule-icon"
                        :src="off"
                        alt="off" />
                    </span>
                    <span v-else-if="date.schedule === 'paidleave'">
                      <img
                        class="yeary-calendar__schedule-icon"
                        :src="paidleave"
                        alt="paidleave" />
                    </span>
                    <div v-else class="yeary-calendar__no-schedule"></div>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="delete-calendar-a my-2" v-show="unAutoAdjusted">
        <span
          class="delete-calendar m-2 d-flex justify-content-end"
          v-on:click="confirmDeleteCalendar"
          >この年のカレンダーの条件と予定を全て削除する
        </span>
      </div>
    </section>
    <section>
      <div class="my-4 rounded alignment-area" v-show="unAutoAdjusted">
        <h2 class="fs-6 m-2">Googleカレンダーに反映するのはこちらから</h2>
        <div class="d-flex justify-content-center">
          <button
            type="button"
            class="btn btn-primary my-2 alignment-button"
            v-on:click="openAlignmentModal">
            連携
          </button>
        </div>
      </div>
      <div
        id="overlay"
        v-show="showAlignmentContent"
        v-on:click.self="closeAlignmentModal">
        <div id="content">
          <Alignment
            v-bind:calendars="calendarIndexes"
            v-on:close="closeAlignmentModal"
            v-on:reflect="reflectGoogleCalendarId">
          </Alignment>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, provide } from 'vue'
import { useToast } from 'vue-toastification'
import Setting from './components/setting.vue'
import Day from './components/day.vue'
import Alignment from './components/alignment.vue'
import Confirm from './components/confirm.vue'
import ScheduleDescription from './components/scheduleDescription.vue'
import fullTime from '../assets/images/fulltime.svg?url'
import morning from '../assets/images/morning.svg?url'
import afterNoon from '../assets/images/afternoon.svg?url'
import off from '../assets/images/off.svg?url'
import paidleave from '../assets/images/paidleave.svg?url'
import { FetchRequest } from '@rails/request.js'

function showPeriod() {
  if (reflectedSetting.value) {
    const periodOfReflectedSetting = `${reflectedSetting.value.period_start_at} ~ ${reflectedSetting.value.period_end_at}`
    return periodOfReflectedSetting
  }
}
const toast = useToast()
onMounted(() => {
  fetchCalendar().then(function () {
    fetchSettings()
  })
  fetchCalendarIndexes()
})
//カレンダー表示関連
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
const loaded = ref(null)
const calendarDays = ref([])
async function fetchCalendar() {
  calendarDays.value = []
  const request = new FetchRequest('get', `/api/v1/calendars/${calendarYear.value}.json`)
  const response = await request.perform()
  if(response.ok) {
    const body = await response.json
    if(body) {
      body.forEach((r) => {
        calendarDays.value.push(r)
      })
    }
    loaded.value = true
  }
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
  let monthlyTotalPaidLeaves = 0
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
      if (schedule === 'paidleave') {
        monthlyTotalPaidLeaves += 1
      }
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
  totalPaidLeaves.value[month] = monthlyTotalPaidLeaves
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
  for (let year = pastYear; year < futureYear; year++) {
    rangeOfYears.push(year)
  }
  return rangeOfYears
})
const monthly = ref(true)
function toMonthlyCalendar(month) {
  calendarMonth.value = month
  monthly.value = true
}
function toYearyCalendar() {
  monthly.value = false
}
//勤務日数カウント関連
const totalWorkingDays = ref({})
const totalPaidLeaves = ref({})
function countWorkingDays(schedule) {
  if (schedule === 'full-time' || schedule === 'paidleave') {
    return 1
  } else if (schedule === 'morning' || schedule === 'afternoon') {
    return 0.5
  }
  return 0
}
function yearyTotalWorkingDays() {
  let totalDays = 0
  for (let i = 1; i <= 12; i++) {
    totalDays += totalWorkingDays.value[i]
  }
  return totalDays
}
function yearyTotalPaidLeaves() {
  let totalDays = 0
  for (let i = 1; i <= 12; i++) {
    totalDays += totalPaidLeaves.value[i]
  }
  return totalDays
}
//自動調整関連
const adjustedCalendar = ref([])
const autoAdjusted = ref(false)
const unAutoAdjusted = computed(() => {
  return !autoAdjusted.value
})
const autoAdjustAll = ref(false)
let targetPeriod = new Array()
const workingDaysRequired = ref(null)
const numberOfWorkingDays = ref(0)
const reflectedSetting = ref(null)
function existInPeriod(date) {
  if (!date.date) {
    return false
  }
  const formatedDate = date.year + '-' + date.month + '-' + date.date
  return targetPeriod.includes(formatedDate)
}
function autoAdjust(setting) {
  const startDate = new Date(setting.period_start_at)
  const endDate = new Date(setting.period_end_at)
  calendarMonth.value = startDate.getMonth() + 1
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
    6: setting.schedule_of_saturday
  }
  // 期間内の日付オブジェクトを利用可能日の配列へ入れる
  for (let day = startDate; day <= endDate; day.setDate(day.getDate() + 1)) {
    const formatedDate =
      day.getFullYear() + '-' + (day.getMonth() + 1) + '-' + day.getDate()
    availableDays.push(formatedDate)
  }
  targetPeriod.push(...availableDays)
  // CalendarDays配列に入っている期間内の日付オブジェクトを抽出し、
  // その日付の勤務予定の日数をカウントし、利用可能日の配列から取り除く
  extractCalendarDaysWithinPeriod(startDate, endDate).forEach((day) => {
    const date = new Date(day.date)
    availableDays.forEach((availableDay) => {
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
    if (schedule === 'None') {
      anyDays.push(availableDay)
      continue
    }
    if (
      workingDaysRequired.value &&
      numberOfWorkingDays.value >= workingDaysRequired.value &&
      !(schedule === 'off')
    ) {
      continue
    }
    numberOfWorkingDays.value += countWorkingDays(schedule)
    insertSchedule(day, schedule)
  }
  if (anyDays.length > 0) {
    for (let anyDay of anyDays) {
      const day = new Date(anyDay)
      if (workingDaysRequired.value - numberOfWorkingDays.value === 0.5) {
        insertSchedule(day, 'morning')
        numberOfWorkingDays.value += 0.5
      } else if (workingDaysRequired.value - numberOfWorkingDays.value >= 1) {
        insertSchedule(day, 'full-time')
        numberOfWorkingDays.value++
      } else {
        break
      }
    }
  }
  reflectedSetting.value = setting
  autoAdjusted.value = true
}
function equalDays(availableDate, date) {
  if (availableDate.getMonth() !== date.getMonth()) {
    return false
  }
  if (availableDate.getDate() !== date.getDate()) {
    return false
  }
  return true
}
function insertSchedule(day, schedule) {
  const formatedDate =
    day.getFullYear() +
    '-' +
    formatMonth(day.getMonth() + 1) +
    '-' +
    formatDay(day.getDate())
  adjustedCalendar.value.push({
    date: formatedDate,
    schedule: schedule
  })
}
function formatMonth(month) {
  return month.toString().padStart(2, '0')
}
function formatDay(day) {
  return day.toString().padStart(2, '0')
}
function reflectAdjustedCalendar() {
  searchAdjustedDay: for (let d of adjustedCalendar.value) {
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
  cancelJustNotConfirm()
  saveAdjustedCalendar()
  autoAdjusted.value = false
  autoAdjustAll.value = false
  targetPeriod = []
}
function cancelAutoAdjust() {
  adjustedCalendar.value = []
  fetchCalendar().then(function () {
    fetchSettings()
  })
  reflectedSetting.value = null
  autoAdjusted.value = false
  autoAdjustAll.value = false
  targetPeriod = []
}
async function saveAdjustedCalendar() {
  const request = new FetchRequest('put', `api/v1/calendars/${calendarYear.value}`, {
    body: JSON.stringify({ calendar: adjustedCalendar.value })
  })
  const response = await request.perform()
  if (response.ok) {
    const body = await response.json
    adjustedCalendar.value = []
    if (body.error_message) {
      toast.error(body.error_message)
      return
    }
    toast(body.message)
  }
}
function adjustAndReflect(setting) {
  async function doAdjustAndReflect() {
    await autoAdjust(setting)
    await reflectAdjustedCalendar()
  }
  doAdjustAndReflect()
}
function adjustAndReflectAll() {
  async function doAdjustAndReflectAll() {
    await autoAdjustFromAllSettings()
    await reflectAdjustedCalendar()
  }
  doAdjustAndReflectAll()
}
function autoAdjustFromAllSettings() {
  for (let setting of settings.value) {
    autoAdjust(setting)
  }
  autoAdjustAll.value = true
  monthly.value = false
}
//条件設定関連
const settings = ref([])
function createToSettings(createdSetting) {
  createdSetting.period_start_at = formatUpdatedDay(
    createdSetting.period_start_at
  )
  createdSetting.period_end_at = formatUpdatedDay(createdSetting.period_end_at)
  settings.value.push(createdSetting)
  sortSettings()
}
function deleteFromSettings(settingId) {
  const found = settings.value.find(setting => setting.id === settingId)
  settings.value.splice(settings.value.indexOf(found), 1)
}
function updateSettings(updatedSetting) {
  updatedSetting.period_start_at = formatUpdatedDay(
    updatedSetting.period_start_at
  )
  updatedSetting.period_end_at = formatUpdatedDay(updatedSetting.period_end_at)
  const found = settings.value.find(setting => setting.id === updatedSetting.id)
  settings.value.splice(settings.value.indexOf(found), 1, updatedSetting)
  sortSettings()
}
provide('settings', { settings, updateSettings, deleteFromSettings, createToSettings })
async function fetchSettings() {
  settings.value = []
  const request = new FetchRequest('get', `api/v1/calendars/${calendarYear.value}/settings.json`)
  const response = await request.perform()
  if(response.ok) {
    const body = await response.json
    if(body) {
      await body.forEach((r) => {
        settings.value.push(r)
      })
    }
    loaded.value = true
    sortSettings()
  }
}
function sortSettings() {
  settings.value.sort((a, b) =>
    a.period_start_at > b.period_start_at ? 1 : -1
  )
}
function formatUpdatedDay(updatedDay) {
  let day = new Date(updatedDay)
  const formatedUpdatedDay =
    day.getFullYear() +
    '-' +
    formatMonth(day.getMonth() + 1) +
    '-' +
    formatDay(day.getDate())
  return formatedUpdatedDay
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
function updateToCalendarArray(calendarDays, newDay) {
  calendarDays.forEach((calendarDay) => {
    if (calendarDay.date === newDay.date) {
      countWorkingDays(calendarDay.schedule) - countWorkingDays(newDay.schedule)
      calendarDays.splice(calendarDays.indexOf(calendarDay), 1, newDay)
      return (
        countWorkingDays(newDay.schedule) -
        countWorkingDays(calendarDay.schedule)
      )
    }
  })
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
  const found = calendarDays.find(calendarDay => calendarDay.date === formatedDay)
  if (found) {
    calendarDays.splice(calendarDays.indexOf(found), 1)
    return countWorkingDays(found.schedule)
  }  
}
// 確認ダイアログ
const showDeleteConfirm = ref(false)
function confirmDeleteCalendar() {
  fetchCalendar().then(function () {
    fetchSettings()
  })
  showDeleteConfirm.value = true
}
function cancelDeleteConfirm() {
  showDeleteConfirm.value = false
}
async function deleteCalendar() {
  const request = new FetchRequest('delete', `api/v1/calendars/${calendarYear.value}`)
  const response = await request.perform()
  if(response.ok) {
    toast('削除しました')
    calendarDays.value = []
    settings.value = []
    deleteFromCalendarIndexes()
    cancelDeleteConfirm()
  }
}
function deleteFromCalendarIndexes() {
  const found = calendarIndexes.value.find(calendarIndex =>  calendarIndex.year === calendarYear.value)
  calendarIndexes.value.splice(calendarIndexes.value.indexOf(found), 1)
}
const showJustNotConfirm = ref(false)
function confirmJustNot() {
  showJustNotConfirm.value = true
}
function cancelJustNotConfirm() {
  showJustNotConfirm.value = false
}
//外部アプリ連携関連
const showAlignmentContent = ref(false)
function openAlignmentModal() {
  fetchCalendarIndexes()
  showAlignmentContent.value = true
}
function closeAlignmentModal() {
  showAlignmentContent.value = false
}
const calendarIndexes = ref([])
async function fetchCalendarIndexes() {
  calendarIndexes.value = []
  const request = new FetchRequest('get', 'api/v1/calendars.json')
  const response = await request.perform()
  if(response.ok) {
    const body = await response.json
    calendarIndexes.value = body
  }
}
function reflectGoogleCalendarId(calendar) {
  const found = calendarIndexes.value.find(calendarIndex =>  calendarIndex.year === calendar.year)
  found.google_calendar_id = calendar.google_calendar_id
}
</script>

<style>
#overlay {
  z-index: 1;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
#content {
  z-index: 2;
  max-width: 500px;
  padding: 1em;
  background: #fff;
}
#confirm {
  z-index: 3;
  max-width: 400px;
  padding: 2em;
  background: #fff;
}
.yeary-calendar__table {
  border: 2px solid black;
  text-align: center;
}
.yeary-calendar__header {
  border: 2px solid black;
}
.yeary-calendar__header-day {
  border: 1px solid black;
}
.yeary-calendar__week {
  border: 1px solid black;
}
.yeary-calendar__day-label {
  font-size: 12px;
}
.yeary-calendar__day {
  border: 1px solid black;
  padding: 1px;
}
.yeary-calendar {
  display: inline-block;
  height: 350px;
}
.yeary-calendar:hover {
  box-shadow: 0px 0px 0px 4px #0099ff;
}
.yeary-calendar__day-body {
  height: 20px;
  display: table-cell;
  vertical-align: middle;
}
.yeary-calendar__schedule-icon {
  width: 16px;
  height: 16px;
}
.yeary-calendar__no-schedule {
  width: 16px;
  height: 24px;
}
.disabled {
  pointer-events: none;
}
.auto-adjusted {
  background-color: lightskyblue;
}
.auto-adjust-info {
  background: rgb(207, 250, 207);
  border: 1px solid greenyellow;
}
.not-just {
  background: #ffbeda;
  border: 1px solid #ff5192;
}
.delete-calendar {
  text-decoration: underline;
  cursor: pointer;
}
.calendar-area {
  display: inline-block;
  text-align: center;
}
.alignment-area {
  background: #e2f3ff;
  border: 1px solid #0099ff;
}
.monthly-calendar__table {
  border: 2px solid black;
  text-align: center;
  width: 100%;
  max-width: 500px;
}
.monthly-calendar__header {
  border: 2px solid black;
}
.monthly-calendar__header-day {
  border: 1px solid black;
}
.monthly-calendar__week {
  border: 1px solid black;
}
.monthly-calendar__day-label {
  font-size: 24px;
}
.monthly-calendar__day {
  border: 1px solid black;
  padding: 4px;
}
th {
  background: whitesmoke;
}
th:first-child {
  background: #fff0f0;
  color: #ff8d99;
}
th:nth-child(7) {
  background: #e2f3ff;
  color: #78a2e6;
}
.monthly-calendar {
  display: inline-block;
}
</style>
