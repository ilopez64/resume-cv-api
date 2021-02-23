package main

import (
	"testing"
)

func TestGetResume(test *testing.T) {
	// Check the response body is what we expect.
	//Future changes to test are needed to compare given w/ expected
	resume := getResume()
	actual := resume.formatResume()
	if len(actual) == 0 {
		test.Errorf("Resume not formatted correctly")
	}
}
