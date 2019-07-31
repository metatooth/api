<template>
  <section class="section">
    <hr>

    <div class="field is-horizontal">
      <div class="field-label">
        <label class="label">
          Filter report
        </label>
      </div>
      <div class="field-body">
        <div class="field is-grouped">
          <div class="control">
            <label class="label">from</label>
          </div>
          <div class="control">
            <input
              v-model="from_date"
              class="input"
              size="10"
              type="text"
              placeholder="For example, 2007-08-03"
            >
          </div>
          <div class="control">
            <label class="label">to</label>
          </div>
          <div class="control">
            <input
              v-model="to_date"
              class="input"
              size="10"
              type="text"
              placeholder="For example, 2009-09-11"
            >
          </div>
        </div>
      </div>
    </div>
    
    <div class="field is-horizontal">
      <div class="field-label" />
      <div class="field-body">
        <div class="field is-grouped">
          <div class="control">
            <a
              class="button is-success"
              @click="filter"
            >Query</a>
          </div>
          <div class="control">
            <a
              class="button is-dark"
              @click="download"
            >Download as HTML</a>
          </div>
        </div>
      </div>
    </div>

    <hr>  
    <table
      v-cloak
      class="table"
    >
      <thead>
        <tr>
          <th>Completed</th>
          <th>Description</th>
          <th style="text-align: center;">
            Duration (hrs)
          </th>
          <th>Notes</th>
          <th
            style="text-align: center;"
            colspan="2"
          >
            Actions
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="task in decoratedTasks" 
          :key="task.id"
          class="task-list"
          :class="{ highlight: task.overlimit }"
        >
          <td>
            {{ task.yyyymmdd }}
          </td>
          <td>
            {{ task.description }}
          </td>
          <td style="text-align: center;">
            {{ (task.duration / 3600) }}
          </td>
          <td>
            <ul>
              <li
                v-for="note in task.notes"
                :key="note.id"
                class="note"
              >
                {{ note.text }}
              </li>
            </ul>
          </td>
          <td class="action-item">
            <a
              class="button is-info"
              @click="edit(task)"
            >
              <span class="icon">
                <i class="fas fa-edit" />
              </span>

            </a>
          </td>
          <td class="action-item">
            <a
              class="button is-warning"
              @click="remove(task)"
            >
              <span class="icon">
                <i class="fas fa-trash" />
              </span>
            </a>     
          </td>
        </tr>
        <tr>
          <td>
            <input
              v-model.trim="completed_on"
              class="input"
              type="text"
              placeholder="YYYY-MM-DD"
            >
          </td>
          <td>
            <input
              v-model.trim="description"
              class="input"
              type="text"
              placeholder="Description"
            >
          </td>
          <td>
            <input
              v-model.number="duration"
              class="input"
              type="number"
              placeholder="Duration (hours)"
              @keyup.enter="save()"
            >
          </td>
          <td />
          <td style="text-align: center;">
            <a
              class="button is-primary"
              :disabled="!isComplete"
              @click="save()"
            >
              <span class="icon">
                <i class="fas fa-save" />
              </span>
            </a>
          </td>
          <td style="text-align: center;">
            <a
              class="button is-light"
              @click="clearTask()"
            >
              <span class="icon">
                <i class="fas fa-times" />
              </span>

            </a>
          </td>
        </tr>
      </tbody>
    </table>
  </section>
</template>

<script>
import TasksService from '../api-services/tasks'

export default {
  props: {
    preferredWorkingSecondsPerDay: {
      type: Number,
      default: 21600
    },
    tasks: {
      type: Array,
      default: function () {
        return new Array()
      }
    },
    onEdit: {
      type: Function,
        default: function () {
          return null        
        }
    },
    token: {
      type: String,
      default: ''
    }
  },
  data: function () {
    return {
      completed_on: '',
      description: '',
      duration: '',
      from_date: '',
      to_date: '',
      errors: '',
      filter_errors: ''
    }
  },
  computed: {
    isComplete: function () {
      return (this.completed_on.length == 10 && this.description.length != 0 && this.duration.length != 0)
    },
    decoratedTasks: function () {
      const daily = new Object
      for (let i = 0; i < this.tasks.length; ++i) {
        const completed_on = new Date(this.tasks[i].completed_on)
        if (!daily[completed_on.yyyymmdd()]) {
          daily[completed_on.yyyymmdd()] = 0 
        }
      
        daily[completed_on.yyyymmdd()] = daily[completed_on.yyyymmdd()] + parseInt(this.tasks[i].duration)
      }

      const filtered = new Array
      for (let i = 0; i < this.tasks.length; ++i) {
        const task = this.tasks[i]
        const completed_on = new Date(task.completed_on)
        
        task.overlimit = (daily[completed_on.yyyymmdd()] > this.preferredWorkingSecondsPerDay)
        task.yyyymmdd = completed_on.yyyymmdd()

        filtered.push(task)
      }

      return filtered.sort(function (a, b) {
        if (new Date(a.completed_on) > new Date(b.completed_on)) {
          return -1
        } else if (new Date(a.completed_on) < new Date(b.completed_on)) {
          return 1
        } else {
          return null
        }
      })
    }
  },
  created: function () {
    const d = new Date()
    this.to_date = this.completed_on = d.yyyymmdd()
    d.setDate(d.getDate() - 30)
    this.from_date = d.yyyymmdd()
  },
  methods: {
    clearTask: function () {
      const d = new Date()
      this.completed_on = d.yyyymmdd()
      this.description = ''
      this.duration = ''
    },
    download: function() {
      this.filter_errors = ''
      if (!this.validDate(this.from_date)) {
        console.log('bad from-date format ' + this.from_date)
        this.filter_errors = 'From Date must be formatted as YYYY-mm-dd'
      } else if (!this.validDate(this.to_date)) {
        console.log('bad to-date format ' + this.to_date)
        this.filter_errors = 'To Date must be formatted as YYYY-mm-dd'
      } else {
        TasksService.download_all(this.token, this.from_date, this.to_date)
          .then(response => {
            const uriContent = "data:application/octet-stream," + encodeURIComponent(response.data)
            window.location = uriContent
        }).catch(error => {
          console.log(error)
        })
      }
    },
    edit: function(task) {
      this.onEdit(task)
    },
    filter: function() {
      this.filter_errors = ''
      if (!this.validDate(this.from_date)) {
        console.log('bad from-date format ' + this.from_date)
        this.filter_errors = 'From Date must be formatted as YYYY-mm-dd'
      } else if (!this.validDate(this.to_date)) {
        console.log('bad to-date format ' + this.to_date)
        this.filter_errors = 'To Date must be formatted as YYYY-mm-dd'
      } else {
        TasksService.get_all(this.token, this.from_date, this.to_date)
          .then(response => {
            this.tasks = response.data
        }).catch(error => {
          console.log(error)
        })
      }
    },
    remove: function (task) {
      if (confirm('Delete task "' + task.description + '". Are you sure?')) {
        TasksService.destroy(task.id, this.token)
          .then(response => {
            this.tasks.splice(this.tasks.indexOf(task), 1)
          }).catch(error => {
            console.log(error)
        })
      }
    },
    save: function () {
      TasksService.create({ completed_on: this.completed_on, description: this.description, duration: this.duration * 3600 }, this.token)
        .then(response => {
          this.tasks.push(response.data)
          this.clearTask()
        }).catch(error => {
          console.log(error)
        })
    },
    validDate: function(str) {
      const re = /^\d\d\d\d-\d\d-\d\d$/
      return re.test(str)
    }
  }
}  
</script>

<style>

ul {
  list-style-type: disc;
}

.section {
  padding-bottom: 0px;
}

.table {
  width: 100%;
}

.task-list {
  background: #bb6666;
}

.highlight {
  background: #66bb66;
}

.action-item {
  text-align: center;
}

</style>