// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 Kent Gibson <warthog618@gmail.com>

/* Minimal example of reading a single line. */

#include <cstdlib>
#include <filesystem>
#include <gpiod.hpp>
#include <iostream>

namespace
{

	/* Example configuration - customize to suit your situation */
	const ::std::filesystem::path chip_path("/dev/gpiochip0");
	const ::gpiod::line::offset line_offset = 5;

} /* namespace */

using namespace gpiod::line;

int main()
{
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
		
		request.set_value(line_offset, value::INACTIVE);
		
	}

	return EXIT_SUCCESS;
}