module hand_module
    use card_module
    implicit none
    
    private
    public :: Hand

    type Hand
        type(Card), allocatable :: cards(:)
        type(Card), allocatable :: unsorted(:)
        type(Card), allocatable :: key_cards(:)
        type(Card), allocatable :: kickers(:)
        character(len=20) :: hand_type = "Unknown"
        
    contains
        procedure :: initialize_hand
        procedure :: evaluate_hand
        procedure :: sort_hand
        procedure :: separate_key_cards_and_kickers
        procedure :: is_flush
        procedure :: is_straight
        procedure :: contains_n_of_a_kind
        procedure :: count_pairs
        procedure :: set_hand_value_to_cards
        procedure :: get_cards
        procedure :: get_unsorted_cards
        procedure :: set_unsorted
        procedure :: compare_to
    end type Hand
    
    
    

contains
    

    subroutine initialize_hand(this, card_array)
        class(Hand), intent(inout) :: this
        type(Card), allocatable :: card_array(:)
        this%cards = card_array
        call this%separate_key_cards_and_kickers()
        call this%sort_hand()
        call this%evaluate_hand()
    end subroutine initialize_hand

    subroutine evaluate_hand(this)
        class(Hand), intent(inout) :: this
        integer :: face_counts(15) = 0
        integer :: i
        logical :: is_flush_flag, is_straight_flag

        ! Count face values
        do i = 1, size(this%cards)
            face_counts(this%cards(i)%get_face_value()) = face_counts(this%cards(i)%get_face_value()) + 1
        end do

        ! Check flush and straight
        is_flush_flag = this%is_flush()
        is_straight_flag = this%is_straight()

        ! Determine hand type
        if (is_flush_flag .and. is_straight_flag) then
            if (face_counts(14) > 0 .and. face_counts(13) > 0) then
                this%hand_type = "Royal Flush"
                call this%set_hand_value_to_cards(10000.0)
            else
                this%hand_type = "Straight Flush"
                call this%set_hand_value_to_cards(9000.0)
            end if
        else if (this%contains_n_of_a_kind(face_counts, 4)) then
            this%hand_type = "Four of a Kind"
            call this%set_hand_value_to_cards(8000.0)
        else if (this%contains_n_of_a_kind(face_counts, 3)) then
            this%hand_type = "Three of a Kind"
            call this%set_hand_value_to_cards(7000.0)
        else if (this%count_pairs(face_counts) == 2) then
            this%hand_type = "Full House"
            call this%set_hand_value_to_cards(6000.0)
        else if (is_flush_flag) then
            this%hand_type = "Flush"
            call this%set_hand_value_to_cards(5000.0)
        else if (is_straight_flag) then
            this%hand_type = "Straight"
            call this%set_hand_value_to_cards(4000.0)
        else
            this%hand_type = "High Card"
            call this%set_hand_value_to_cards(1000.0)
        end if
    end subroutine evaluate_hand

    subroutine sort_hand(this)
        use card_module
        implicit none
        class(Hand), intent(inout) :: this
        integer :: i, j
        type(Card) :: temp_card
    
        ! Sort keyCards in descending order of hand value
        do i = 1, size(this%key_cards) - 1
            do j = i + 1, size(this%key_cards)
                if (this%key_cards(j)%get_hand_value() > this%key_cards(i)%get_hand_value()) then
                    temp_card = this%key_cards(i)
                    this%key_cards(i) = this%key_cards(j)
                    this%key_cards(j) = temp_card
                end if
            end do
        end do
    
        ! Sort kickers in descending order of hand value
        do i = 1, size(this%kickers) - 1
            do j = i + 1, size(this%kickers)
                if (this%kickers(j)%get_hand_value() > this%kickers(i)%get_hand_value()) then
                    temp_card = this%kickers(i)
                    this%kickers(i) = this%kickers(j)
                    this%kickers(j) = temp_card
                end if
            end do
        end do
    
        ! Combine key cards and kickers into the final sorted hand
        this%cards = this%key_cards  ! Start with key cards
        this%cards = [this%cards, this%kickers]  ! Append kickers
    
        ! Handle the special case for a straight with a high ace
        if (is_straight(this) .and. this%cards(1)%get_face_value() == 14 .and. this%cards(5)%get_face_value() == 2) then
            this%cards = [this%cards(1), this%cards]  ! Add the first card to the front
            this%cards = this%cards(2:size(this%cards))  ! Remove the original first card
        end if
    
    end subroutine sort_hand

    subroutine separate_key_cards_and_kickers(this)
        use card_module
        implicit none
        class(Hand), intent(inout) :: this
        integer :: face_counts(15) = 0  ! Assuming face values are from 1 to 14
        integer :: i, card_value
        integer :: key_count, kicker_count  ! Declare key_count and kicker_count
    
        ! Initialize temporary arrays for key cards and kickers
        type(Card), allocatable :: temp_key_cards(:)
        type(Card), allocatable :: temp_kickers(:)
    
        ! Count the occurrences of each face value
        do i = 1, size(this%cards)
            card_value = this%cards(i)%get_face_value()  ! Call method to get face value
            face_counts(card_value) = face_counts(card_value) + 1
        end do
    
        ! Determine the counts of key cards and kickers
        key_count = 0
        kicker_count = 0
    
        do i = 1, size(this%cards)
            card_value = this%cards(i)%get_face_value()  ! Call method to get face value
            if (face_counts(card_value) > 1) then
                key_count = key_count + 1
            else
                kicker_count = kicker_count + 1
            end if
        end do
    
        ! Allocate temporary arrays
        allocate(temp_key_cards(key_count))
        allocate(temp_kickers(kicker_count))
    
        ! Add key cards to temp_key_cards and remaining cards to temp_kickers
        key_count = 0
        kicker_count = 0
    
        do i = 1, size(this%cards)
            card_value = this%cards(i)%get_face_value()  ! Call method to get face value
            if (face_counts(card_value) > 1) then
                key_count = key_count + 1
                temp_key_cards(key_count) = this%cards(i)
            else
                kicker_count = kicker_count + 1
                temp_kickers(kicker_count) = this%cards(i)
            end if
        end do
    
        allocate(this%key_cards(key_count))
        allocate(this%kickers(kicker_count))
    
            ! Copy the contents of temp_key_cards to this%key_cards
        do i = 1, key_count
            this%key_cards(i) = temp_key_cards(i)
        end do
    
        ! Copy the contents of temp_kickers to this%kickers
        do i = 1, kicker_count
            this%kickers(i) = temp_kickers(i)
        end do
    
    end subroutine separate_key_cards_and_kickers

    logical function is_flush(this)
        implicit none
        class(Hand), intent(in) :: this
        integer :: i , suit
    
        ! Get the suit of the first card
        suit = this%cards(1)%get_suit_value()
    
        ! Check if all cards have the same suit
        do i = 2, size(this%cards)  ! Start from the second card
            if (this%cards(i)%get_suit_value() /= suit) then
                is_flush = .false.
                return
            end if
        end do
    
        is_flush = .true.
    end function is_flush

    logical function is_straight(this)
        implicit none
        class(Hand), intent(in) :: this
        integer :: values(5)  ! Assuming the hand has 5 cards
        integer :: i, j, temp
    
        ! Extract face values from the cards
        do i = 1, size(this%cards)
            values(i) = this%cards(i)%get_face_value()
        end do
    
        ! Bubble sort the values
        do i = 1, size(values) - 1
            do j = 1, size(values) - i
                if (values(j) > values(j + 1)) then
                    ! Swap
                    temp = values(j)
                    values(j) = values(j + 1)
                    values(j + 1) = temp
                end if
            end do
        end do
    
        ! Check for high Ace straight (10-J-Q-K-A)
        if (values(1) == 2 .and. values(5) == 14 .and. &
            values(2) == 3 .and. values(3) == 4 .and. values(4) == 5) then
            is_straight = .true.
            return
        end if
    
        ! Check for consecutive values
        do i = 2, size(values)
            if (values(i) /= values(i - 1) + 1) then
                is_straight = .false.
                return
            end if
        end do
    
        is_straight = .true.
    end function is_straight

    logical function contains_n_of_a_kind(this, face_counts, n) result(found)
        class(Hand), intent(in) :: this
        integer, intent(in) :: face_counts(:)
        integer, intent(in) :: n
        integer :: index
        found = .false.  ! Initialize to false
        do index = 1, size(face_counts)
            if (face_counts(index) == n) then
                found = .true.  ! Found n of a kind
                return
            end if
        end do
    end function contains_n_of_a_kind

    integer function count_pairs(this, face_counts) result(pair_count)
        class(Hand), intent(in) :: this
        integer, intent(in) :: face_counts(:)
        integer :: index

        pair_count = 0  ! Initialize count to zero
        do index = 1, size(face_counts)
            if (face_counts(index) == 2) pair_count = pair_count + 1  ! Increment for each pair
        end do
    end function count_pairs

    subroutine set_hand_value_to_cards(this, base_value)
        class(Hand), intent(inout) :: this
        real(4), intent(in) :: base_value
        integer :: i
        real(4) :: hand_value

        do i = 1, size(this%cards)
            if (this%hand_type /= "One Pair" .and. this%hand_type /= "Two Pair") then
                hand_value = base_value + this%cards(i)%get_face_value() + this%cards(i)%get_suit_value()
            else
                hand_value = base_value + this%cards(i)%get_face_value()
            end if
            call this%cards(i)%set_hand_value(hand_value)
        end do
    end subroutine set_hand_value_to_cards

    function get_cards(this) result(card_array)
        class(Hand), intent(in) :: this
        type(Card), allocatable :: card_array(:)
        card_array = this%cards
    end function get_cards

    function get_unsorted_cards(this) result(unsorted_array)
        class(Hand), intent(in) :: this
        type(Card), allocatable :: unsorted_array(:)
        unsorted_array = this%unsorted
    end function get_unsorted_cards

    subroutine set_unsorted(this, card_array)
        class(Hand), intent(inout) :: this
        type(Card), allocatable :: card_array(:)
        this%unsorted = card_array  ! Set the unsorted cards
    end subroutine set_unsorted

    ! Method to compare two hands
    function compare_to(this, other) result(comparison_result)
        class(Hand), intent(inout) :: this
        class(Hand), intent(in) :: other
        integer :: i
        integer :: comparison_result

        ! Compare key cards first
        do i = 1, size(this%key_cards)
            if (this%cards(i)%get_hand_value() > other%cards(i)%get_hand_value()) then
                comparison_result = 1
                return
            else if (this%cards(i)%get_hand_value() < other%cards(i)%get_hand_value()) then
                comparison_result = -1
                return
            end if
        end do
        
        do i = 1, size(this%cards)
            call this%cards(i)%set_hand_value(this%cards(i)%get_suit_value())
        end do

        ! If key cards are equal, compare kickers
        do i = size(this%key_cards), size(this%cards)
            if (this%cards(i)%get_hand_value() > other%cards(i)%get_hand_value()) then
                comparison_result = 1
                return
            else if (this%cards(i)%get_hand_value() < other%cards(i)%get_hand_value()) then
                comparison_result = -1
                return
            end if
        end do

        comparison_result = 0  ! Hands are equal if all comparisons are equal
    end function compare_to

end module hand_module