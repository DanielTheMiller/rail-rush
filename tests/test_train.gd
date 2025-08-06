extends GutTest

func test_passes():
	# this test will pass because 1 does equal 1
	assert_not_null(get_tree())
	assert_eq(1, 1)
