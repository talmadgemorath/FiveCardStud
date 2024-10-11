module card_utils
    use card_module
    use hand_module
    implicit none

contains

    subroutine create_ordered_deck(deck)
        type(Card), allocatable :: deck(:)
        integer :: i, j, k
        character(len=2) :: faces(13) = [ ' 2', ' 3', ' 4', ' 5', ' 6', ' 7', ' 8', ' 9', '10', ' J', ' Q', ' K', ' A' ]
        character(len=1) :: suits(4) = [ 'D', 'C', 'H', 'S' ]
        allocate(deck(52))

        j = 1
        do i = 1, 4
            do k = 1, 13
                deck(j) = Card()
                deck(j)%face = trim(adjustl(faces(k)))
                deck(j)%suit = suits(i)
                j = j + 1
            end do
        end do
    end subroutine create_ordered_deck

    subroutine shuffle_deck(deck)
        type(Card), allocatable :: deck(:)
        integer :: i, j
        type(Card) :: temp
        real :: rand

        do i = size(deck), 2, -1
            call random_number(rand)
            j = 1 + int(rand * i)
            temp = deck(i)
            deck(i) = deck(j)
            deck(j) = temp
        end do
    end subroutine shuffle_deck

    subroutine display_deck(deck)
        type(Card), allocatable :: deck(:)
        integer :: i
        character(len=100) :: line  ! Adjust size as needed
    
        line = ""  ! Initialize the line to an empty string
        do i = 1, size(deck)
            line = trim(line) // " " // deck(i)%to_string() // " "  ! Concatenate card to line
    
            if (mod(i, 13) == 0) then
                print *, trim(line)  ! Print the line after every 13 cards
                line = ""  ! Reset line for the next set of cards
            end if
        end do
    
        ! Print any remaining cards in the line
        if (trim(line) /= "") then
            print *, trim(line)
        end if
    end subroutine display_deck

    subroutine display_hand(handx)
        use hand_module
        type(Hand), intent(in) :: handx
        integer :: i
        character(len=100) :: line  ! Adjust size as needed
    
        line = ""  ! Initialize the line to an empty string
        do i = 1, size(handx%cards)
            line = trim(line)// " " // trim(handx%cards(i)%to_string()) // " "  ! Concatenate card to line
        end do
    
        print *, trim(line)  ! Print the entire hand on one line
    end subroutine display_hand

    subroutine remove_dealt_cards(deck)
        use card_module
        type(Card), allocatable :: deck(:)
        integer :: dealt_count = 30
        type(Card), allocatable :: deck2(:)
        integer :: i, j, new_size
    
        ! Calculate the new size after removing dealt cards
        new_size = size(deck) - dealt_count
        allocate(deck2(new_size))
    
        j = 1
        do i = 1, size(deck)
            if (i > dealt_count) then  ! Copy only undealt cards
                deck2(j) = deck(i)
                j = j + 1
            end if
        end do
    
        ! Deallocate the old deck and assign the new deck to it
        deallocate(deck)
        deck = deck2
    end subroutine remove_dealt_cards

    subroutine split_line(line, card_records)
    character(len=200), intent(in) :: line
    character(len=20), allocatable :: card_records(:)
    character(len=200) :: temp
    integer :: i, count, start, end

    ! Initialize variables
    count = 0
    start = 1
    temp = trim(line)

    ! Count the number of cards (delimited by commas)
    do while (len_trim(temp) > 0)
        end = index(temp, ',')  ! Find position of the next comma

        if (end == 0) then
            end = len_trim(temp)  ! No more commas, take the rest of the string
        endif

        count = count + 1

        ! Extract the card and update temp
        card_records(count) = trim(adjustl(temp(start:end)))
        temp = temp(end + 1:)  ! Move to the next part of the string
        start = 1              ! Reset start for the next iteration
    end do

    ! Resize the card_records array to the actual count
    if (count < size(card_records)) then
        allocate(character(len=20) :: card_records(count))
    endif
end subroutine split_line

    function card_in_seen_cards(card, seen_cards) result(found)
        character(len=20), intent(in) :: card
        character(len=20), allocatable :: seen_cards(:)
        logical :: found
        integer :: i

        found = .false.
        do i = 1, size(seen_cards)
            if (trim(seen_cards(i)) == trim(card)) then
                found = .true.
                exit
            end if
        end do
    end function card_in_seen_cards
    
        subroutine sort(hands, temp)
    use hand_module
    type(Hand), allocatable, intent(inout) :: hands(:)
    type(Hand), intent(inout) :: temp 
    integer :: i, j, x

    ! Simple bubble sort for demonstration
    do i = 1, size(hands) - 1
        do j = 1, size(hands) - i
            x = hands(j)%compare_to(hands(j + 1))
            if (x < 0) then
                ! Swap hands(j) and hands(j + 1) using temp
                temp = hands(j)             ! Store hands(j) in temp
                hands(j) = hands(j + 1)     ! Copy hands(j + 1) to hands(j)
                hands(j + 1) = temp          ! Copy temp (old hands(j)) to hands(j + 1)
            end if
        end do
    end do
end subroutine sort

subroutine reverse(hands, temp)
    use hand_module
    type(Hand), allocatable, intent(inout) :: hands(:)
    type(Hand), intent(inout) :: temp  
    integer :: i, n

    n = size(hands)
    do i = 1, n / 2
        ! Swap hands(i) and hands(n - i + 1) using temp
        temp = hands(i)                ! Store hands(i) in temp
        hands(i) = hands(n - i + 1)    ! Copy hands(n - i + 1) to hands(i)
        hands(n - i + 1) = temp        ! Copy temp (old hands(i)) to hands(n - i + 1)
    end do
end subroutine reverse
    
end module card_utils

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

program FiveCard
    use card_module
    use hand_module
    use card_utils
    use iso_fortran_env
    implicit none

    type(Card), allocatable :: deck(:)
    type(Hand), allocatable :: hands(:)
    integer :: i, ios, hand_count
    character(len=100) :: file_path
    logical :: has_duplicate
    character(len=20) :: duplicate_card
    character(len=200) :: line
    character(len=20), allocatable :: seen_cards(:)
    character(len=20), allocatable :: card_records(:)
    character(len=2) :: card_face
    character(len=1) :: card_suit
    character(len=20) :: cardx
    character(len=20) :: trimmed_record
    type(Hand), allocatable :: temp  
    type(Card), allocatable :: temp_cards(:)

    if (command_argument_count() == 0) then
        call create_ordered_deck(deck)
        call shuffle_deck(deck)

        print *, "*** P O K E R H A N D A N A L Y Z E R ***"
        print *
        print *, "*** USING RANDOMIZED DECK OF CARDS ***"
        print *
        print *, "*** Shuffled 52 card deck:"
        call display_deck(deck)
        print *

        print *, "*** Here are the six hands..."
        allocate(hands(6))
        allocate(temp_cards(5))  
        do i = 1, 6
            temp_cards = deck((i-1)*5 + 1:i*5)
            call hands(i)%initialize_hand(temp_cards)
            call hands(i)%set_unsorted(temp_cards)
            call display_hand(hands(i))
        end do
        
        print *

        call remove_dealt_cards(deck)
        print *, "*** Here is what remains in the deck..."
        call display_deck(deck)
        
        print *
        
        temp = Hand()
        
        !! Sort hands based on their poker rank
        call sort(hands,temp)
        
        
        !! Reverse the order of hands to show the highest rank first
        !call reverse(hands,temp)
        
        
        print *, "--- WINNING HAND ORDER ---"
        
        !! Display each hand with its rank name
        do i= 1, size(hands)
            call display_hand(hands(i))
            print *, hands(i)%hand_type
        enddo
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    else
        call GET_COMMAND_ARGUMENT(1, file_path)

        print *, "*** P O K E R H A N D A N A L Y Z E R ***"
        print *
        print *, "*** USING TEST DECK ***"
        print *
        print *, "*** File: ", trim(file_path)

        open(unit=10, file=trim(file_path), status='old', iostat=ios)
        if (ios /= 0) then
            print *, "*** ERROR - COULD NOT OPEN FILE ***"
            stop
        end if

        ! Read and print each line from the file
    
        do
            read(10, '(A)', iostat=ios) line  ! Read a line from the file
            if (ios /= 0) exit  ! Exit loop if end of file or error
    
            print *, trim(line)  ! Print the line to the screen
        end do
        
        print *
        
        print *, "*** Here are the six hands..."

        has_duplicate = .false.
        allocate(seen_cards(100))
        hand_count = 0

        
        close(10)

        ! Sort and display the hands
        ! Additional logic to sort hands goes here...
    end if
end program FiveCard

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
