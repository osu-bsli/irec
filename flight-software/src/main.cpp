// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 Kent Gibson <warthog618@gmail.com>

/* Minimal example of reading a single line. */

#include <cstdlib>
#include <filesystem>
#include <gpiod.hpp>
#include <iostream>
#include <unistd.h>

namespace
{

	/* Example configuration - customize to suit your situation */
	const ::std::filesystem::path chip_path("/dev/gpiochip0");
	const ::gpiod::line::offset line_offset = 5;

} /* namespace */

using namespace gpiod::line;

int main()
{
	printf("BSLI IREC Flight Software coming right up!\n");
	auto request = ::gpiod::chip(chip_path)
					   .prepare_request()
					   .set_consumer("set-line-value")
					   .add_line_settings(
						   line_offset,
						   ::gpiod::line_settings().set_direction(
							   ::gpiod::line::direction::OUTPUT))
					   .do_request();

	while (1)
	{
		request.set_value(line_offset, value::ACTIVE);
		usleep(1000*500);
		request.set_value(line_offset, value::INACTIVE);
		usleep(1000*500);
	}

	return EXIT_SUCCESS;
}
