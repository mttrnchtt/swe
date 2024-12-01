package scheduler

import "github.com/go-co-op/gocron/v2"

type Configurer interface {
	ConfigureJobDefinition() gocron.JobDefinition
	ConfigureJobTask() gocron.Task
}
