# -*- coding: utf-8 -*-


def lcc(string):
    max_char, max_count, prev_char, count = None, 0, None, 0

    for char in string:
        if char == prev_char:
            count += 1
        else:
            count = 1

        if count >= max_count:
            max_char = char
            max_count = count

        prev_char = char

    return {max_char: max_count}


if __name__ == '__main__':
    string = input('Enter string: ')
    print('Longest consecutive character: {}'.format(lcc(string)))
