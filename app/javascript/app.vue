<template>
  <button v-on:click="openModal">条件の入力</button>
    <div id=overlay  v-show="showContent">
      <div id=content>
        <Setting v-bind:year="calendarYear"
               v-bind:settings="settings"
               v-on:close="closeModal"
               v-on:update="updateSetting"
               v-on:create="createSetting"
               v-on:delete="deleteSetting">
        </Setting>
      </div>
    </div>
  <button class="calendar-nav__previous" @click='previousMonth'>前</button>
  <button class="calendar-nav__next" @click='nextMonth'>後</button>
  <select id='specifiy_calendar_year' v-model.number="calendarYear" @change="cancelAutoAdjust">
    <option v-for="year in rangeOfYears" :key="year">{{ year }}</option>
  </select>
  <select id='specifiy_calendar_month' v-show="monthly" v-model.number="calendarMonth">
    <option v-for="month in 12" :key="month">{{ month }}</option>
  </select>
  <div v-if="monthly">
    <div class="calendar-nav__year--month">{{ calendarYear }}年{{ calendarMonth }}月 合計:{{ totalWorkingDays[this.calendarMonth] }}</div>
    <button v-on:click="this.monthly=false">年間カレンダー</button>
    <table class="calendar">
      <thead class="calendar__header">
        <tr>
          <th class="calendar__header-day">日</th>
          <th class="calendar__header-day">月</th>
          <th class="calendar__header-day">火</th>
          <th class="calendar__header-day">水</th>
          <th class="calendar__header-day">木</th>
          <th class="calendar__header-day">金</th>
          <th class="calendar__header-day">土</th>
        </tr>
      </thead>
      <tbody v-for="week in calendarWeeks(this.calendarMonth)" :key="week.id">
        <tr class="calendar__week">
          <td class="calendar__day" 
            v-for='date in week.value'
            :key='date.date'
            :id="'day' + date.date">
            <div class="calendar__day-label">{{ date.date }}</div>
            <Day v-bind:date="date" 
                 v-if="date.date"
                 v-on:update="updateDay"
                 v-on:delete="deleteDay">
            </Day>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
  <div v-else>
    <div class="calendar-nav__year">{{ calendarYear }}年 合計:{{ yearyTotalWorkingDays() }}</div>
    <div class="calendar-month" v-for="month in 12" :key="month">{{ month }}月 合計:{{ totalWorkingDays[month] }}
      <div v-on:click="toMonthlyCalendar(month)"> 
        <table class="calendar">
          <thead class="calendar__header">
            <tr>
              <th class="calendar__header-day">日</th>
              <th class="calendar__header-day">月</th>
              <th class="calendar__header-day">火</th>
              <th class="calendar__header-day">水</th>
              <th class="calendar__header-day">木</th>
              <th class="calendar__header-day">金</th>
              <th class="calendar__header-day">土</th>
            </tr>
          </thead>
          <tbody v-for="week in calendarWeeks(month)" :key="week.id">
            <tr class="calendar__week">
              <td class="calendar__day" 
                v-for='date in week.value'
                :key='date.date'
                :id="'day' + date.date">
                <div class="calendar__day-label">{{ date.date }}</div>
                <div>{{ scheduleToMark[date.schedule] }}</div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
  <button v-show="unAutoAdjusted" v-on:click="autoAdjust">適用</button>
  <button v-show="autoAdjusted" v-on:click="determineAutoAdjust">確定</button>
  <button v-show="autoAdjusted" v-on:click="cancelAutoAdjust">キャンセル</button>
  <button v-on:click="openAlignmentModal">連携</button>
    <div id=overlay  v-show="showAlinmentContent">
      <div id=content>
        <Alignment v-bind:calendars="calendarsIndex"
                   v-on:close="closeAlignmentModal"
                   v-on:create="createAlignment"
                   v-on:delete="deleteAlignment"
                   v-on:update="updateAlignment">
        </Alignment>
      </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import Setting from './components/setting.vue' 
import Day from './components/day.vue' 
import Alignment from './components/alignment.vue'

export default defineComponent({
  name: 'Calendar',
  data() {
    return {
      schedules: ["●","▲","△","□"],
      markToSchedule: { "●":"full-time", "▲":"morning", "△":"afternoon", "□":"off" },
      scheduleToMark: { "full-time":"●", "morning":"▲", "afternoon":"△", "off":"□" },
      calendarDays: [],
      settings: [],
      currentYear: this.getCurrentYear(),
      currentMonth: this.getCurrentMonth(),
      calendarYear: this.getCurrentYear(),
      calendarMonth: this.getCurrentMonth(),
      today: this.getCurrentDay(),
      loaded: null,
      showContent: false,
      showAlinmentContent: false,
      adjastedCalendar: [],
      totalWorkingDays: {},
      autoAdjusted: false,
      calendarsIndex: [],
      monthly: true,
    }
  },
  props: {
    userId: { type: String, required: true }
  },
  computed: {
    unAutoAdjusted() {
      return !this.autoAdjusted
    },
    rangeOfYears() {
      let rangeOfYears = []
      const yearRangeNumber = 10
      const pastYear = this.getCurrentYear() - yearRangeNumber
      const futureYear = this.getCurrentYear() + yearRangeNumber
      for (let year = pastYear;year < futureYear;year++) {
        rangeOfYears.push(year)
      }
      return rangeOfYears
    },
  },
  mounted() {
    this.fetchCalendarAndSettings()
    this.fetchCalendarsIndex()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    formatDay(day) {
      return day.toString().padStart(2, '0')
    },
    formatMonth(month) {
      return month.toString().padStart(2, '0')
    },
    getCurrentYear() {
      return new Date().getFullYear()
    },
    getCurrentMonth() {
      return new Date().getMonth() + 1
    },
    getCurrentDay() {
      return new Date().getDate()
    },
    previousMonth() {
      this.loaded = false
      if (this.calendarMonth === 1) {
        this.calendarMonth = 12
        this.calendarYear--
        this.cancelAutoAdjust()
      } else {
        this.calendarMonth--
      }
      this.$nextTick(() => (this.loaded = true))
    },
    nextMonth() {
      this.loaded = false
      if (this.calendarMonth === 12) {
        this.calendarMonth = 1
        this.calendarYear++
        this.cancelAutoAdjust()
      } else {
        this.calendarMonth++
      }
      this.$nextTick(() => (this.loaded = true))
    },
    fetchCalendar() {
      this.calendarDays = []
      fetch(`/api/calendars/${this.calendarYear}.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token()
      },
      credentials: 'same-origin'
      })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        json.forEach((r) => {
          this.calendarDays.push(r)
        })
        this.loaded = true
      })
      .catch((error) => {
        console.warn(error)
      })
    },
    openModal() {
      this.showContent = true
    },
    closeModal() {
      this.showContent = false
    },
    openAlignmentModal() {
      this.showAlinmentContent = true
    },
    closeAlignmentModal() {
      this.showAlinmentContent = false
    },
    autoAdjust() {
      this.adjustedCalendar = []
      for (let setting of this.settings) {
        const startDate = new Date(setting.period_start_at)
        const endDate = new Date(setting.period_end_at)
        let availableDays = new Array()
        const workingDaysRequired = setting.total_working_days
        let numberOfWorkingDays = 0
        const schedulesOfWeek = { 
          0: setting.schedule_of_sunday,
          1: setting.schedule_of_monday,
          2: setting.schedule_of_tuesday,
          3: setting.schedule_of_wednesday,
          4: setting.schedule_of_thursday,
          5: setting.schedule_of_friday,
          6: setting.schedule_of_saturday,
        }
        for (let day = startDate; day <= endDate; day.setDate(day.getDate()+1)) {
          const formatedDate = day.getFullYear() + "-" + (day.getMonth()+1) + "-" + day.getDate()
          availableDays.push(formatedDate)
        }
        this.extractCalendarDaysWithinPeriod(startDate, endDate).forEach(day=> {
          const date = new Date(day.date)
          availableDays.forEach(availableDay=> {
            const availableDate = new Date(availableDay)
            if (this.equalDays(availableDate, date)) {
              if (day.schedule === 'full-time') {
                numberOfWorkingDays++
              } else if ((day.schedule === 'morning') || (day.schedule === 'afternoon')) {
                numberOfWorkingDays+=0.5
              }
              availableDays.splice(availableDays.indexOf(availableDay), 1)
            }
          })
        })
        for (let availableDay of availableDays) {
          const day = new Date(availableDay)
          const schedule = schedulesOfWeek[day.getDay()]
          if (schedule === "None") { continue }
          if ((numberOfWorkingDays >= workingDaysRequired) && !(schedule === "off")) {
            continue
          }
          this.insertSchedule(day, schedule)
          if (schedule === 'full-time') {
            numberOfWorkingDays++
          } else if ((schedule === 'morning') || (schedule === 'afternoon')) {
            numberOfWorkingDays+=0.5
          }
        }
      }
      this.reflectAdjustedCalendar()
      this.autoAdjusted = true
    },
    insertSchedule(day, schedule) {
      const formatedDate = day.getFullYear() + "-" + this.formatMonth(day.getMonth()+1) + "-" + this.formatDay(day.getDate())
      this.adjustedCalendar.push({
        date: formatedDate,
        schedule: schedule,
      })
    },
    fetchSettings() {
      this.settings = []
      fetch(`api/calendars/${this.calendarYear}/settings.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin'
      })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        json.forEach((r) => {
          this.settings.push(r)
        })
        this.loaded = true
      })
      .then(()=> {
        this.settings.sort((a, b)=>
          a.period_start_at > b.period_start_at ? 1 : -1
        )
      })
      .catch((error) => {
        console.warn(error)
      })
    },
    reflectAdjustedCalendar() {
      searchAdjustedDay:
      for (let d of this.adjustedCalendar) {
        for (let day of this.calendarDays) {
          if (day.date === d.date) {
            this.calendarDays.splice(this.calendarDays.indexOf(day), 1, d)
            continue searchAdjustedDay
          }
        }
        this.calendarDays.push(d)
      }
    },
    fetchCalendarAndSettings() {
      (async () => {
        await this.fetchCalendar()
        await this.fetchSettings()
      })()
    },
    extractCalendarDaysWithinPeriod(startDate, endDate) {
      const calendar = new Array()
      for (let day of this.calendarDays) {
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
    },
    equalDays(availableDate, date) {
      if (availableDate.getMonth() !== date.getMonth()) { return false }
      if (availableDate.getDate() !== date.getDate()) { return false }
      return true
    },
    determineAutoAdjust() {
      this.saveAdjustedCalendar()
      this.autoAdjusted = false
    },
    cancelAutoAdjust() {
      this.adjustedCalendar = [],
      this.fetchCalendarAndSettings()
      this.autoAdjusted = false
    },
    saveAdjustedCalendar() {
      fetch(`api/calendars/${this.calendarYear}`, {
      method: 'PUT',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ "calendar": this.adjustedCalendar }),
      credentials: 'same-origin'
      })
      .catch((error) => {
        console.warn(error)
      })
    },
    updateSetting(updatedSetting) {
      updatedSetting.period_start_at = this.formatUpdatedDay(updatedSetting.period_start_at)
      updatedSetting.period_end_at = this.formatUpdatedDay(updatedSetting.period_end_at)
      for (let setting of this.settings) {
        if(setting.id === updatedSetting.id) {
          this.settings.splice(this.settings.indexOf(setting), 1, updatedSetting)
          break
        }
      }
    },
    formatUpdatedDay(updatedDay) {
      let day = new Date(updatedDay)
      const formatedUpdatedDay = day.getFullYear() + "-" + this.formatMonth(day.getMonth() + 1) + "-" + this.formatDay(day.getDate())
      return formatedUpdatedDay
    },
    createSetting(createdSetting) {
      createdSetting.period_start_at = this.formatUpdatedDay(createdSetting.period_start_at)
      createdSetting.period_end_at = this.formatUpdatedDay(createdSetting.period_end_at)
      this.settings.push(createdSetting)
    },
    deleteSetting(settingId) {
      for (let setting of this.settings) {
        if (setting.id === settingId) {
          this.settings.splice(this.settings.indexOf(setting), 1)
          break
        }
      }
    },
    updateDay(day) {
      const date = new Date(day.year, day.month - 1, day.date)
      const formatedDay = this.formatUpdatedDay(date)
      const newDay = { date: formatedDay, schedule: day.schedule }
      for (let calendarDay of this.calendarDays) {
        if (calendarDay.date === formatedDay) {
          this.calendarDays.splice(this.calendarDays.indexOf(calendarDay), 1, newDay)
        }
        break
      }
      this.calendarDays.push(newDay)
    },
    deleteDay(day) {
      const date = new Date(day.year, day.month - 1, day.date)
      const formatedDay = this.formatUpdatedDay(date)
      for (let calendarDay of this.calendarDays) {
        if (calendarDay.date === formatedDay) {
          this.calendarDays.splice(this.calendarDays.indexOf(calendarDay), 1)
          break
        }
      }
    },
    fetchCalendarsIndex() {
      this.calendarsIndex = []
      fetch('api/calendars', {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token()
      },
      credentials: 'same-origin'
      })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        json.forEach((r) => {
          this.calendarsIndex.push(r)
        })
      })
      .then(()=> {
        this.calendarsIndex.sort((a, b)=>
          a.year - b.year
        )
      })
      .catch((error) => {
        console.warn(error)
      })
    },
    createAlignment(calendar) {
      for (let calendarIndex of this.calendarsIndex) {
        if (calendarIndex.year === calendar.year) {
          calendarIndex.google_calendar_id = calendar.google_calendar_id
          break
        }
      }
    },
    deleteAlignment(calendar) {
      for (let calendarIndex of this.calendarsIndex) {
        if (calendarIndex.year === calendar.year) {
          calendarIndex.google_calendar_id = null
          break
        }
      }
    },
    updateAlignment(calendar) {
      for (let calendarIndex of this.calendarsIndex) {
        if (calendarIndex.year === calendar.year) {
          calendarIndex.google_calendar_id = calendar.google_calendar_id
          break
        }
      }
    },
    toMonthlyCalendar(month) {
      this.calendarMonth = month
      this.monthly = true
    },
    firstWday(month) {
      const firstDay = new Date(this.calendarYear, month - 1, 1)
      return firstDay.getDay()
    },
    lastDate(month) {
      const lastDay = new Date(this.calendarYear, month, 0)
      return lastDay.getDate()
    },
    calendarWeeks(month) {
      const weeksAry = []
      let value = []
      let id = 1
      let weekDay = 0
      this.calendarDates(month).forEach(function (date, i, ary) {
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
    },
    calendarDates(month) {
      const calendar = []
      let monthlyTotalWorkingDays = 0
      if (this.firstWday(month) > 0) {
        for (let blank = 0; blank < this.firstWday(month); blank++) {
          calendar.push(null)
        }
      }
      for (let date = 1; date <= this.lastDate(month); date++) {
        const result = this.calendarDays.filter((day) =>
          day.date.includes(
            `${this.calendarYear}-${this.formatMonth(month)}-${this.formatDay(date)}`
          )
        )
        if (result.length > 0) {
          const schedule = String(result[0].schedule)
          calendar.push({ 
            date: date,
            schedule: schedule,
            year: this.calendarYear,
            month: month
          })
          monthlyTotalWorkingDays += this.countTotalWorkingDays(schedule) 
        } else {
          calendar.push({
            date: date, 
            schedule: null,
            year: this.calendarYear,
            month: month
          })
        }
      }
      this.totalWorkingDays[month] = monthlyTotalWorkingDays
      return calendar
    },
    countTotalWorkingDays(schedule) {
      if (schedule === 'full-time') {
        return 1
      } else if ((schedule === 'morning') || (schedule === 'afternoon')) {
        return 0.5
      }
      return 0
    },
    yearyTotalWorkingDays(){
      let totalWorkingDays = 0
      for (let i = 1; i <= 12; i++) {
        totalWorkingDays += this.totalWorkingDays[i]
      }
      return totalWorkingDays
    },
  },
  components: {
    Setting,
    Day,
    Alignment,
  },
})
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
.calendar-month{
  display: inline-block;
}
</style>