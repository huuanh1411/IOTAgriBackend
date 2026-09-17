using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IOTAgriBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddDeviceProvisioning : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ProvisionedAt",
                table: "Devices",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProvisionedHardwareId",
                table: "Devices",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ProvisioningCodeExpiresAt",
                table: "Devices",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProvisioningCodeHash",
                table: "Devices",
                type: "text",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Devices_ProvisionedHardwareId",
                table: "Devices",
                column: "ProvisionedHardwareId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Devices_ProvisionedHardwareId",
                table: "Devices");

            migrationBuilder.DropColumn(
                name: "ProvisionedAt",
                table: "Devices");

            migrationBuilder.DropColumn(
                name: "ProvisionedHardwareId",
                table: "Devices");

            migrationBuilder.DropColumn(
                name: "ProvisioningCodeExpiresAt",
                table: "Devices");

            migrationBuilder.DropColumn(
                name: "ProvisioningCodeHash",
                table: "Devices");
        }
    }
}
