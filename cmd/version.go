package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

const version = "v0.7.6"

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version number of Terraformer",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Terraformer " + version)
	},
}
