module communicator_test
    use communicator, only: communicator_t
    use garden, only: result_t, test_item_t, assert_equals, describe, fail, it
    use iso_varying_string, only: operator(//)
    use strff, only: to_string

    implicit none
    private
    public :: test_communicator
contains
    function test_communicator() result(tests)
        type(test_item_t) :: tests

        tests = describe( &
            "A communicator", &
            [ it("can transmit integers", check_integer_transmission) &
            , it("can transmit characters", check_character_transmission) &
            ])
    end function

    function check_integer_transmission() result(result_)
        type(result_t) :: result_

        type(communicator_t) :: comm

        integer, parameter :: expected_val = 42
        class(*), allocatable :: received
        integer :: i, j

        associate(me => this_image(), ni => num_images())
            if (ni == 1) then
                result_ = fail("Can't run test with only 1 image")
            else
                call comm%init()
                do i = 1, ni
                    if (me == i) then
                        do j = 1, ni
                            if (me /= j) then
                                call comm%send_to(j, expected_val)
                            end if
                        end do
                    else
                        call comm%receive_from(i, received)
                        select type (received)
                        type is (integer)
                            result_ = result_.and.assert_equals( &
                                    expected_val, &
                                    received, &
                                    "On image " // to_string(me) &
                                    // " from image " // to_string(i))
                        class default
                            result_ = result_.and.fail(&
                                    "Didn't receive an integer on image " &
                                    // to_string(me) // " from image " // to_string(i))
                        end select
                    end if
                end do
            end if
        end associate
    end function

    function check_character_transmission() result(result_)
        type(result_t) :: result_

        type(communicator_t) :: comm

        character(len=*), parameter :: expected_val = "Hello, World!"
        class(*), allocatable :: received
        integer :: i, j

        associate(me => this_image(), ni => num_images())
            if (ni == 1) then
                result_ = fail("Can't run test with only 1 image")
            else
                call comm%init()
                do i = 1, ni
                    if (me == i) then
                        do j = 1, ni
                            if (me /= j) then
                                call comm%send_to(j, expected_val)
                            end if
                        end do
                    else
                        call comm%receive_from(i, received)
                        select type (received)
                        type is (character(len=*))
                            result_ = result_.and.assert_equals( &
                                    expected_val, &
                                    received, &
                                    "On image " // to_string(me) &
                                    // " from image " // to_string(i))
                        class default
                            result_ = result_.and.fail(&
                                    "Didn't receive an integer on image " &
                                    // to_string(me) // " from image " // to_string(i))
                        end select
                    end if
                end do
            end if
        end associate
    end function
end module